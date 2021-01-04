require "json"

class StackGraph
  HTML_HEADER = <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title>Racc stack graph</title>
        <link rel="stylesheet" href="stack_graph.css" type="text/css" />
        <script src="stack_graph.js"></script>
      </head>
      <body>
  HTML

  HTML_FOOTER = <<~HTML
      </body>
    </html>
  HTML

  class Block < Struct.new(:from, :to, :token, :layer)
  end

  def initialize(
        log,
        color_map: {},
        step_width: 6 # rem
      )
    @log = log
    @color_map = color_map
    @step_width = step_width
  end

  def print_tag(tag, attrs)
    print "<#{tag} #{attrs}>"
    yield
    print "</#{tag}>"
  end

  def rand_color
    format(
      "rgb(%d, %d, %d)",
      128 + rand(127),
      128 + rand(127),
      128 + rand(127)
    )
  end

  def make_blocks(vstack_list)
    blocks = []
    current = []
    num_layers = vstack_list.map(&:size).max

    vstack_list.each_with_index do |vstack, step|
      
      (0...num_layers).each do |layer|
        v = vstack[layer]

        if current[layer].nil?
          if v.nil?
            ;
          else
            # 出現
            block = Block.new(step, step, v, layer)
            blocks << block
            current[layer] = block
          end
        else
          if v.nil?
            # 消滅
            current[layer] = nil
          else
            if v == current[layer].token
              # 継続
              current[layer].to = step
            else
              # 変更
              block = Block.new(step, step, v, layer)
              blocks << block
              current[layer] = block
            end
          end
        end
      end
    end

    blocks
  end

  def bgcolor(bl)
    @color_map.fetch(bl.token[0]) { rand_color() }
  end

  def print_graph(vstack_list, blocks)
    num_layers = vstack_list.map(&:size).max

    (0...num_layers).to_a.reverse.each do |layer| # 上から下へ
      layer_blocks =
        blocks
          .select { |bl| bl.layer == layer }
          .sort { |a, b| a.from <=> b.from }

      step = 0
      print_tag "div", %(class="layer_container") do
        layer_blocks.each do |bl| # 左から右へ
          blank_steps = bl.from - step
          blank_steps.times do
            print %(<div class="block_space" style="width: #{@step_width}rem;"> </div>)
          end
          step = bl.to + 1

          w = @step_width * (bl.to - bl.from + 1)
          print_tag "div", %(class="block" style="width: #{w}rem; background: #{bgcolor(bl)};") do
            sym, val = bl.token
            print sym
            print %(<hr />)
            print val
          end
        end
      end
    end

    print_tag "div", %(class="layer_container") do
      (0...(vstack_list.size)).to_a
        .map(&:succ)
        .each { |step| print %(<div class="block" style="width: #{@step_width}rem;">#{step}</div>) }
    end
  end

  def print_html
    vstack_list = @log.lines .map { |line| JSON.parse(line) }
    blocks = make_blocks(vstack_list)

    puts HTML_HEADER

    print_tag "div", %(style="width: #{ @step_width * vstack_list.size + 4 }rem; padding: 2rem;") do
      print_graph(vstack_list, blocks)
    end

    puts HTML_FOOTER
  end
end

if $0 == __FILE__
  color_map = {
    "IDENT"   => "rgb(225, 233, 151)",
    "STRING"  => "rgb(225, 233, 151)",
    "INT"     => "rgb(225, 233, 151)",
    "primary" => "rgb(162, 234, 231)",
    "expr"    => "#fb6",
    "empty"   => "#eee",
  }

  sg = StackGraph.new(
    ARGF.read,
    color_map: color_map,
    step_width: 8
  )
  sg.print_html
end
