class Game
  def initialize
    @dictionary = load_dictionary('dictionary.txt')
    @correct_guesses = []
    @answer = find_word.split('')
    @display = Array.new(@answer.length, '_')
    @incorrect_guesses = []
  end

  def load_dictionary(filename)
    File.readlines(filename)
  end

  def find_word
    word = ''
    word = @dictionary[rand(0..@dictionary.length)].chomp while word.length < 5 || word.length > 12
    word.chomp
  end

  def request_input
    input = gets.chomp
    validate_input(input)
    create_display
  end

  def validate_input(input)
    if @answer.include?(input)
      p "It contains #{input}"
      modify_display(input)
    else
      p "It doesn't contain #{input}"
    end
  end

  def create_display
    @display.each { |element| print "#{element} " }
  end

  def modify_display(input)
    @answer.each_with_index do |letter, index|
      @display[index] = input if input == letter
    end
  end

  def play_game
    puts 'Welcome to Hangman!'
    puts 'A word has been selected for you...'
    puts 'Please enter a letter.'
    create_display
    request_input while @display.join != @answer.join
  end
end

game = Game.new
game.play_game