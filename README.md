# copyrep

Script to replace copyright headers of supported source code files based on the provided `copyright.erb` template.

## Usage

### Run with Maven

```
mvn exec:java -Dsourcedir=<source directory>
```

The `sourcedir` property must point to the directory which contains the source files, e.g.:

```
mvn exec:java -Dsourcedir=c:/project/c360-cex-bundle
```

You can run unit tests with the `mvn exec:java -Ptest` command.

### Run directly with Ruby

```
ruby copyrep.rb <source directory>
```

You can run unit tests with the `rake` command.

Requires Ruby 2.5 or newer
