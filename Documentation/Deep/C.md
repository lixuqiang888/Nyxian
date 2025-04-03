## Implementing C into iOS coding app

Second of all we arent the people making the interpreter, we are the developer that make the coding apps it self. As we dont have JIT on iOS.. what are available options... I will order the best to the worst option ive ever discovered. To protect you I will also only include open source projects that are usable for other open source projects.

## Options

###### [Picoc](https://github.com/jpoirier/picoc)

We could use use interpreters like [Picoc](https://github.com/jpoirier/picoc) which is a **very small** C interpreter that also **does many mistakes at interpreting C code** and **it's support is very slim**. On the other hand **its extremely easy to implement**. It also **only supports a few C headers** because its all interpreted from scratch. **It isint even fully ISO C**.