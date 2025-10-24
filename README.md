# NiceToHave Swift functions
This package provides Swift functions that you write all over and over. So instead of write the same function again, the function can be accessed from this package.



# Generate tokens from exported Material Design Figma json 

``` Swift
    cd {root of project}
    swift package plugin generate-code \
    --schema { path to your json schema } \
    --output { path to the output folder } \
  --type main | module. If you generate to the project: main, if you generate to a swift package: module
```
