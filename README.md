# TimeBars.jl
This package supplies abstract element types (\"bars\") designed to be subtyped and used to do tabular work in a lightweight and simple array container (`StructArray`). The type tree represents more specialized tabular and time series functionality as you go deeper.

## Purpose
The idea is to provide a time series tables framework that provides a good tradeoff between type stability and flexibility. We want to be able to easily dispatch on different subtypes of tables so we can write efficient and generic functions. We want array element subtyping with specialized semantics / functionality to enable lots of code reuse (with a sensible type hierarchy). We want it to be simple to understand, use, and extend. We want the interface to be idiomatic Julia.

For a long ramble on why I started developing this and ongoing design choices, see RATIONALE.md.

