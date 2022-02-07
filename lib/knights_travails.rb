require 'pry-byebug'

class Node
  attr_accessor :data, :path, :children

  def initialize(data, path = [], children = [])
    @data = data
    @children = children
    @path = path
  end
end

class Tree < Node
  attr_accessor :start, :last, :root, :matrix, :answer

  def initialize(start, last)
    super(start, last)
    @start = start
    @last = last
    @matrix = []
    (0...8).each do |x_position|
      (0...8).each do |y_position|
        @matrix.push([x_position, y_position])
      end
    end
    @root = play_game(start, last)
  end

  def play_game(start, last)
    if !start.all? {|element| element.between?(0, 7)} || !last.all? { |element| element.between?(0, 7) }
      puts "Error: start or last is out of bounds.  Coordinates must be between 0 and 7 in format '[0,0]'"
      return
    elsif start == last
      puts "Error: start or last are same coordinate" if start == last
      return
    end
    build_tree
  end

  def build_tree(node = nil, queue = [])
    if @root.nil? && !block_given?
      @root = Node.new(start)
      node = @root
    end

    (-2..2).each do |x_move|
      (-2..2).each do |y_move|
        if x_move.abs != y_move.abs && !x_move.zero? && !y_move.zero?
          test_vector = node.data.zip([x_move, y_move]).map { |element| element.first + element.last }
          if test_vector == @last
            # binding.pry
            puts "You made it in #{node.path.length + 1} moves!  Here's your path:"
            p start
            node.path.each { |vector| p vector }
            p test_vector
            @answer = node.path.length + 1
            return
          elsif test_vector[0].between?(0, 8) && test_vector[1].between?(0, 8) && @matrix.include?(test_vector)
            # binding.pry
            @matrix.delete(test_vector)
            new_path = Array.new(node.path).push(test_vector)
            node.children.push(Node.new(test_vector, new_path))

          end
        end
      end
    end
    # binding.pry
    node.children.each { |child| queue.push(child) }
    next_node = queue.shift
    build_tree(next_node, queue)
  end
end

def knight_moves(start, last)
  Tree.new(start, last)
end

test_array = []
(0..7).each do |x_start|
  (0..7).each do |y_start|
    (0..7).each do |x_finish|
      (0..7).each do |y_finish|
        array_start = [x_start, y_start]
        array_finish = [x_finish, y_finish]
        test_array.push(knight_moves(array_start, array_finish)) unless array_start == array_finish
      end
    end
  end
end
answer_array = []
test_array.each do |element|
  answer_array.push(element.answer)
end
dict = answer_array.reduce({}) { |sum_hash, element| sum_hash[element] = (sum_hash[element] || 0) + 1; sum_hash}
puts dict
puts test_array.all? { |element| element.answer.between?(1, 6) }