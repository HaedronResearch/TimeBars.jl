# TimeBars.jl
This package supplies abstract element types (\"bars\") designed to be subtyped and used to do tabular work in a lightweight and simple array container (`StructArray`). The type tree represents more specialized tabular and time series functionality as you go deeper.

## Purpose
The idea is to provide a time series tables framework that provides a good tradeoff between type stability and flexibility. We want to be able to easily dispatch on different subtypes of tables so we can write efficient and generic functions. We want array element subtyping with specialized semantics / functionality to enable lots of code reuse (with a sensible type hierarchy). We want it to be simple to understand, use, and extend. We want the interface to be idiomatic Julia.

For a long ramble on why I started developing this and ongoing design choices, see RATIONALE.md.

## Overview
`TimeBars.jl` supplies abstract element types to be used with `StructArray`s (from [StructArrays.jl](https://juliaarrays.github.io/StructArrays.jl/stable/)). As the abstract types move from most to least abstract, they gain functionality and assumptions. 

### Type Tree and Subtyping
The type tree is a simple line (`Bar` is the root type):

```
Bar >: IndexedBar >: SeriesBar >: TimeSeriesBar >: TimeTypeBar
```

Subtype them with your own concrete element types to gain the functionality. See `src/bar/concrete/ohlc.bar.jl` for a simple example of subtyping a `TimeTypeBar`.

This package is intended mainly for time series use; only the following types are exported: `TimeSeriesBar`, `TimeTypeBar`. The others exist mainly to organize functionality, but can still be subtyped directly if you want (e.g. non-time series or other uniquely indexed observations). View the docstrings of each type for their semantics and other details.

### `IndexedBar` and `TimeBars.index`
Most useful bars directly or indirectly subtype `IndexedBar`. Any `MyBar <: IndexedBar` must supply methods for a function called `TimeBars.index`. Specifically, the following:

* `TimeBars.index(bar::MyIndexedBar)`: returns index field(s) of a bar
* `TimeBars.index(arr::StructArray{<:MyIndexedBar})`: return index array of a `StructArray{<:IndexedBar}`

For a single-valued index, we just use the values themselves. For a multi-valued index, we use a `NamedTuple` / `StructArray{<:NamedTuple}` though this may change in the future. See the docstring for `IndexedBar` and `TimeBars.index` for more details. 

### `Base.isvalid`
* Caling `isvalid` on your concrete bar type will verify that your type validly implements the parent bar interface. You should always do this after defining your concrete type.
* Calling `isvalid` on an instance of your bar will verify runtime attributes (can be slow).

### `Base.convert`
`StructArray.jl`'s SOA memory layout makes it simple and efficient to convert between tables.
#### Downconversions
If one concrete bar type, `BarA`, is a subset of another concrete bar type, `BarB`, then `StructArray{BarB}`->`StructArray{BarA}` is free. This allows us to define our methods which only need the fields of `BarA` and efficiently use them will all superset Bars like `BarB` (`Base.convert` still need to be explicitly called, but wrapper functions dont need to know anything about the content of `BarA` or `BarB`).

#### Upconversions
If you want to convert to a bar with more fields (`StructArray{BarA}`->`StructArray{BarB}`), then you need to define `Base.convert` methods for this purpose. This is also typically a cheap and easy operation with StructArrays.
