# TimeBars.jl
Disclaimer: This package is early in development and I am experimenting with how things work.

## Why this Package?
There have been many approaches to working with time series that have been introduced in Julia.

Of the most popular approaches, on one side you have `AbstractArray` and on the other you have `DataFrames.jl`. I use standard arrays a lot, but a table-like structure is nice for when you have columns of different types, or when you need to add lots of columns and change the structure a lot. DataFrames.jl is particularly nice for that second case. I don't use tables much in my time series work, but I do sometimes use them.

However, when it comes to time series I always felt like something was missing. One thing I realized is that my main use for tables is for operations that are entirely relative to the timestamp. Things like resampling, expanding the index, shifting, groupby aggregation (over the timestamps), and so on. When all that is done, I convert to arrays and do the "real work". Most of the interesting stuff I have is for `AbstractArray`.

If you look at `DataFrames.jl`, there is a lot of functionality (and complexity) that it provides that I don't need. I'm generally not adding many columns or doing very complicated querying on the DataFrame/table. I just need basic operations, that are almost always relative to a timestamp index column. I made `DateTimeDataFrames.jl` to work with `DataFrame` in that context. However, there was still things niggling me about `DataFrames.jl`. It's on the heavy side, it has things I don't want/need, and (subjectively) I've found parts of the interface unintuitive. They kind of steer you away from Julia interfaces and concepts (e.g. `filter` and broadcasting). There is also the type-instability aspect of DataFrames (perhaps the importance of which has been overblown for most table use cases).

One of the things I always wanted was the ability to specialize on different kinds of tables (i.e. with different columns). If you don't make the columns part of the type, you lose a lot of power. I find the multiple dispatch and type functionality of Julia to be among the most powerful features of the language.

There are a number of "timeseries table" packages. They do nice things, but they also tend to add on a lot I don't want (e.g. arbitrary operations like "percent change"). They end up adding on things I don't want for a table package. I just want a simple, efficient time series table package to do the basic things above.

I did a search for table and array-adjacent packages. I distinguish a table from an array-like structure by the capability of the former to have columns (or dimensions) of different concrete types (i.e. without a `Union` or abstract element type). Finding 10+ table and array things, one of them stood out: `StructArrays.jl`.

Basically, it seemed like exactly what I wanted from a table. It is simple to use, efficient (using an SOA memory layout), and allows dispatching on subtypes. Not only that, it was even an `AbstractArray`! You can't easily mutate them to add columns, but that isn't something I often need. For the times when I may need that, I can define different element types (structs) or `NamedTuple`s for `StructArray` and convert between them.

## Purpose
To summarize the purpose of this package, we want to provide:
* A structured type tree for time series and their row elements, that admits dispatch and allows users to easily subtype to create efficient and maintainable (low-code) data pipelines
* Related to the previous, we want to provide some common index-relative operations
* We want the type tree to be easy to add to, enabling methods to be "pushed upstream" as far as possible
* An efficient underlying implementation; this is supplied by `StructArrays.jl`
* A simple interface to work with time series that is idiomatic with Julia

## Type Hierarchy
So I thought about how I could use `StructArray` for time series. Among financial practicioners, there is something called a "bar". Bars are a series of prices indexed in time. For example, an OHLC bar. There is also the notion of "time bars" vs "alternate bars", but that doesn't really matter here. Basically both are indexed in time, but the second one may be irregularly sampled. All financial data are time series.

So the notion of this package is really simple. A `Bar` is a named set of values (could be represented by a `NamedTuple`). For example, an OHLC (open, high, low, close) bar. When a (unique) index is attached to a `Bar`, we get `IndexedBar`.

Under this we have, `SeriesBar`, that is an ordinal (sequential) indexed `Bar`. All it needs is to have some field(s) that have ordinal value (i.e. a bunch of SeriesBars could be sorted by that subset). For time series, this is obviously the timestamp, but technically this could be subtyped for other purposes (e.g. a value changing over space).

Think of a mathematical [process](https://en.wikipedia.org/wiki/Stochastic_process). The ordinal value is the value of an index set for that set of bars, e.g. a time index set for a time series. I thought about using `Process` in the name for this type, but I think `SeriesBar` is less confusing. Technically, the process is the actual mathematical specification rather than realizations of that process, which is what `SeriesBar` is.

Subtyping `SeriesBar`, we have `TimeSeriesBar`. This is a `SeriesBar` whose index set is some kind of time measurement. As the name suggests, a set of these is some kind of time series. In many cases, this ordinal value will be a subtype of `Dates.TimeType`, but there may be many other time series ordinal representations. Best to keep it general and not specify. Also a TimeSeriesBar doesn't imply a regular sampling frequency, just that it's indexed by time.

Below `TimeSeriesBar` there is `TimeTypeBar` which does imply a `Dates.TimeType` is part of the indexing values.

## Using TimeBars
To use these types, you subtype one of these abstract types and define the `index` method for your subtype. Of course you may define or override methods for your subtype. A simple example is in `src/bar/concrete/ohlc.jl`.

## Single and Multi Index
For a single index bar series, `index` is simple to define; it is just returns the index column.

Sometimes we may want multi column indices. For now, I accomplish this with `NamedTuple` of a subset of columns. StructArrays work well with NamedTuple element types, so I think this works fine. The `index` function needs to define the unique index of the time series bars. The multi index functionality is something I am still working out, so how this works may change in the future (for example, using a separate type for the index part of an `IndexedBar`).

## Functionality
* deduplication
* lag/lead
* downsample
* regularity checking
* groupby

## Transducers.jl
I am experimenting with using `Transducers.jl` for operations I am commonly using. Transducers provides a functional interface for operations on sequences. Hopefully, we can avoid the definition of too many operations in this package and instead have it be easily interoperable with `Transducers.jl` and other existing packages.

## Data Field Constraints
This package is intended to supply abstract types and methods that can supply a lot of generic functionality. One of the challenges is that abstract Bars cant easily and generically support constraints on the data fields in child bars types (only concrete types have fields). Nevertheless, having the abiltiy to constrain and dispatch on abstract bars that have known data fields would be useful. For example, we can guarantee that a particular family of bars would have this or that data field that we need in calculations of some function. We can then define methods for that subset of bars and cheap `convert` methods (cheap because StructArrays are all SOA) from superset bars.

Currently, I use the same method of setting constraints for data fields as index fields. That is to have some `isvalid` methods that check for the existence of accessor methods. Using isvalid to assert constraints is imperfect in general. While it is only one line, the user has to remember to include it after defining their type. In practice, the requirements for concrete bars are simple and straightforward so it is hard to get implementation wrong in any case.

The bigger issue is that including data field constraints in the abstract type tree makes is not an orthogonal design. There may be cases where we want the same data field constraints on different branches of the Bar type tree. This isnt a problem yet, but it easily can be. There are a few other ways to constrain fieldtypes of subtype bars.

 One way is to consider enforcing data field constraints in methods using trait dispatching. This is conceptually the cleanest and most flexible, but it would force user methods to be tied to some traits package (Julia has no official traits in Base or canonical traits methodology).

The next conceptually best way would be to change the Bar type tree and semantics of Bars. A Bar consists of some fields. An IndexedBar of some indexing fields and some data fields. It may be better to fork the components of the bar so that some components hold only data and some hold only indices. One or both components could be used as a valid bar. This would make the design orthogonal and could work. Still, there are two issues. The first is that it would require a lot of changes and would increase complexity. The second more important issue is that StructArrays allow nested element types, but seem to work better (and more simply) with flat structs. I would prefer to keep the structs flat because they are easier to reason about and are less likely to lead to performance pitfalls.

Another way would be to only have data fields encoded in the concrete bars and use `convert` to move from higher field to minimal field bars (as long as the fields of the source is a superset of the target, this will work). Currently, the `convert` method is already defined for this kind of discard-based conversion (ie conversion where some data fields are discarded). This is easily done with StructArrays. While this would work, it has downsides. Methods dispatching on parts of a bar would have to be defined with concrete types, which forces the data field values to be of particular types.

There may be a way to use type parameters to encode constraints on data fields. The downside to this is that it can get ugly with many field additions required. It's also probably not good style.

## Notes on Style
* https://docs.julialang.org/en/v1/manual/methods/#Abstract-containers-and-element-types