---
title:  "Using LENS in Scala"
---

Immutable objects are recommended for use in Scala. 
To update a field of immutable object, we can use case class copy function.
This way is good for simple cases, but think about deeper nested objects, it looks bad.

An example for a simple domain model:

{% highlight scala %}
case class Address(no: String, 
                   street: String, 
                   district: String, 
                   city: String)
case class Company(taxCode: String, 
                   name: String, 
                   address: Address)

val a = Address("111", "Nguyen Hue", "Q1", "HCM")
val c = Company("123", "ABC", a)
// Now company name is changing to "ABC Corp"
val nc = c.copy(name = "ABC Corp")
{% endhighlight %}

This looks good. Then we want to update a field of Address

{% highlight scala %}
// Now the company is changing its address to 
// the new one: #222, Nguyen Hue street, HCM city
val nc = c.copy(address = c.address.copy(no = "222"))
{% endhighlight %}

Look not so good if more level of nested objects

Then LENS to the rescue. So what is LENS?

*lenses are the pure functional equivalent of references (or pointers) to a sub-element of a complex data structure (or, rather, data value)*

But how can we implement by this way to resolve the problem above?

We simply abstract the way of accessing/mutating a field of type V on an object of type O as following:

{% highlight scala %}
/**
* O: type of the object we want to get or set
* V: type of the field of the object we want to get or set
*/
case class Lens[O, V](
    get: O => V,
    set: (O, V) => O
)
{% endhighlight %}

Want to access/mutate fields of an object?
{% highlight scala %}
val addressNoLens = Lens[Address, String](
    get = _.no,
    set = (a: Address, newNo: String) => a.copy(no = newNo)
)
addressNoLens.get(a) 
addressNoLens.set(a, "222")

val companyAddrLens = Lens[Company, Address](
    get = _.address,
    set = (c: Company, newAddr: Address) => c.copy(address = newAddr)
)
companyAddrLens.get(c)
val newAddr = a.copy(no = "222")
companyAddrLens.set(c, newAddr)
{% endhighlight %}

But how about accessing/mutating fields of nested objects -> We need a Lens[Company, String].
Actually, this can be composed of companyAddrLens and addressNoLens using the following function:
{% highlight scala %}
def compose[L0, L1, L2](outerLens: Lens[L0, L1], 
                        innerLens: Lens[L1, L2]) = {
    Lens[L0, L2](
        get = outerLens.get andThen innerLens.get,
        set = (outerObject: L0, innerValue: L2) => 
            outerLens.set(
                outerObject, 
                innerLens.set(outerLens.get(outerObject), innerValue)
            )
    )
}
val companyAddrNoLens = compose(companyAddrLens, addressNoLens)
companyAddrNoLens.get(c) 
companyAddrNoLens.set(c, "222")
{% endhighlight %}

Finally, there are many Lens libraries out there such as [Monocle][github-monocle] or [Scalaz][github-scalaz]
For example, with Monocle, just declare the dependency in build sbt, then import classes for use:

{% highlight scala %}
val addressNoLens = Lens[Address, String]
    (_.no)(newNo => a => a.copy(no = newNo))
val companyAddrLens = Lens[Company, Address]
    (_.address)(newAddr => c => c.copy(address = newAddr))
val companyAddrNoLens = companyAddrLens composeLens addressNoLens
companyAddrNoLens.set("222")(c)
{% endhighlight %}

[github-monocle]: https://github.com/julien-truffaut/Monocle
[github-scalaz]: https://github.com/scalaz/scalaz