# -*- mode: ruby -*-

class Parser

rule
  expr: INT "+" INT
  {
    puts "expression found"
    result = val
  }
end

---- header

require "json"

---- inner

def initialize
  # ↓両方とも必要
  @yydebug = true
  # ↓これがないとターミナルにプリントされる
  @racc_debug_out = File.open("debug.log", "wb")

  @racc_stack_out = File.open("stack.log", "wb")
end

# Override Racc::Parser#racc_print_stacks
def racc_print_stacks(t, v)
  super(t, v)
  stack = t.zip(v).map { |t, v| [racc_token2str(t), v] }
  @racc_stack_out.puts JSON.generate(stack)
end

def next_token
  @tokens.shift
end

def parse(src)
  @tokens = src.split(" ").map { |s|
    case s
    when /^\d+$/ then [:INT, s.to_i]
    else              [s, s]
    end
  }
  @tokens << [false, false]

  do_parse
end

---- footer

src = ARGV[0]
result = Parser.new().parse(src)
puts "result: " + result.inspect
