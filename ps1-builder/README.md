# polyglot script with arguments and administrator
adapted from: http://stackoverflow.com/questions/9366080/batch-launching-powershell-with-a-multiline-command-parameter

do not start any lines in your ps1 with ```@@#```



# Accessing arguments

# command line arguments passed to the original .bat file are accessed via $Script:arguments
# ```$Script:arguments[0]``` is the original .bat file location
# ```$Script:arguments[1]``` is the first argument
# ```$Script:arguments[2]``` is the second argument
