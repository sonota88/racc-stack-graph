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
  # parser.rb を使ったときにデバッグ情報を出力する
  @yydebug = true
  # デバッグ情報の出力先をファイルに変更（デフォルトでは標準エラー出力） …… これは必須ではない
  @racc_debug_out = File.open("debug.log", "wb")

  @racc_stack_out = File.open("stack.log", "wb")
end

# Override Racc::Parser#racc_print_stacks
def racc_print_stacks(tstack, vstack)
  super(tstack, vstack)
  stack = tstack.zip(vstack).map { |t, v| [racc_token2str(t), v] }
  @racc_stack_out.puts JSON.generate(stack)
end

def next_token
  @tokens.shift
end

def parse(src)
  @tokens = src.split(" ").map do |s|
    case s
    when /^\d+$/ then [:INT, s.to_i]
    else              [s, s]
    end
  end
  @tokens << [false, false]

  do_parse
end

---- footer

src = ARGV[0]
result = Parser.new().parse(src)
puts "result: " + result.inspect
