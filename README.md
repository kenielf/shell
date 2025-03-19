# Custom Modular Shell Configuration
## How it works
This configuration uses the concept of modules to dynamically load components 
that I use in my daily life, whilst checking for dependencies and having 
support for autostarting custom functions automatically.

This allows me to reuse core functions when needed, whilst also keeping the
flexibility to add or remove modules as I like.

## Creating your own modules
You can add your own custom modules by creating a `.sh` file (POSIX syntax is 
strongly recommended) and following these rules:
 1. Custom internal shell functions must start with an underscore (`_`);
 2. Custom internal shell functions must not be called on the file
    > As in top level commands, since these will be executed when sourced 
    > which is **NOT ALLOWED** for this configuration schema
 3. Custom user-facing commands must not start with an underscore
 4. Declare command dependencies with `_dependency_add "command"`
 5. Add autostart functions with `_autostart_add "function"`
    > These are the functions you define, and not commands - since spaces 
    > **will** break the configuration.

## Installation
Clone the repository and run the bootstrap command:
```bash
git clone https://github.com/kenielf/shell
cd shell
./bootstrap.sh
source ~/.bashrc

```
> [!NOTE]
> You can clone the repository to wherever you'd like, but when installed it
> will symlink itself to ~/.config/shell

## License
This project is [MIT licensed](/LICENSE) and forking is **strongly** encouraged.
