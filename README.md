# MethodWrappers
Pharo method wrappers for performance analysis.

I'm a self contained package and I can be loaded with:
```smalltalk
Metacello new
    baseline: 'MethodWrappers';
    repository: 'github://bauing-schmidt/MethodWrappers/src';
    load.
```
After that, a presenter can be used with
```smalltalk
(MethodsTemperaturesPresenter on: aBaseline) openWithSpec .
```
where `aBaseline` is a baseline class you want to start with for your profiling.
