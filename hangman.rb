require 'yaml'

class Hangman
  def initialize
    @dictionary = load_dictionary('dictionary.txt')
    @letters_used = []
    @answer = find_word
    @answer_split = @answer.split('')
    @display = Array.new(@answer_split.length, '_')
    @round_counter = 0
    @rounds = 6
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
    if @round_counter > @rounds
      you_lost
    else
      create_display
      puts "\n\nPlease enter a character."
      input = gets.chomp
      @letters_used.push(input)
      validate_input(input)
      continue_or_save
    end
  end

  def continue_or_save
    puts 'Would you like to continue or save?'
    puts '1. Continue'
    puts '2. Save'
    answer = gets.chomp
    case answer
    when '1' then continue_game
    when '2' then save_game
    end
  end

  def save_game
    game_state = YAML.dump({
      answer: @answer,
      letters_used: @letters_used,
      answer_split: @answer_split,
      display: @display,
      rounds_counter: @rounds_counter,
      rounds: @rounds
    })
    File.open('./hangman.yml', 'w') { |f| f.write game_state }
    exit
  end

  def load_game
    yaml = YAML.load_file('./hangman.yml')
    deserialize(yaml)
    continue_game
  end

  def deserialize(file)
    @answer = file[:answer]
    @letters_used = file[:letters_used]
    @answer_split = file[:answer_split]
    @display = file[:display]
    @rounds_counter = file[:rounds_counter]
    @rounds = file[:rounds]
  end

  def validate_input(input)
    @answer_split.include?(input) ? result_positive(input) : result_negative(input)
  end

  def result_positive(input)
    modify_display(input)
    create_display
    puts "\n\nIt contains #{input}. [#{@round_counter}/#{@rounds}]. Letters used: #{@letters_used.uniq}."
  end

  def result_negative(input)
    @round_counter += 1
    you_lost if @round_counter > @rounds
    create_display
    puts "\n\nIt doesn't contain #{input}. [#{@round_counter}/#{@rounds}]. Letters used: #{@letters_used.uniq}."
  end

  def create_display
    @display.each { |element| print "#{element} " }
  end

  def modify_display(input)
    @answer_split.each_with_index do |letter, index|
      @display[index] = input if input == letter
    end
  end
end

class Game < Hangman
  def game_start
    reset_game
    puts "Welcome to Hangman!\n\n"
    puts 'Would you like to play a new game or load a game?'
    puts '1. New game'
    puts '2. Load game'
    answer = gets.chomp
    case answer
    when '1' then play_game
    when '2' then load_game
    end
  end

  def play_game
    puts "A word has been selected for you...\n\n"
    continue_game
    you_won
  end

  def reset_game
    system 'clear'
    @letters_used = []
    @answer = find_word
    @answer_split = @answer.split('')
    @display = Array.new(@answer_split.length, '_')
    @round_counter = 0
  end

  def continue_game
    if @display.join == @answer_split.join
      you_won
    else
      request_input
    end
  end

  def play_again
    puts 'Would you like to play again? (y/n)'
    response = gets.chomp
    case response.downcase
    when 'y' then play_game
    when 'n' then exit
    else
      puts 'Please enter either y (yes), or n (no).'
    end
  end

  def you_lost
    puts "\nUnfortunately you didn't guess the word in time..."
    puts "The answer was #{@answer}."
    play_again
  end

  def you_won
    puts 'Congratulations you guessed the word correctly!'
    play_again
  end
end

game = Game.new
game.game_start
