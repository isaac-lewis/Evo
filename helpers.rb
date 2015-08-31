class Array
  def describe(commas=", ", and_str=' and ')
    speakable = self.select {|n| !n.nil? and n != ""}

    case speakable.count
      when 0 then ''
      when 1 then speakable[0].describe
      else
      descriptions = speakable.map(&:describe)

      if commas == ", "
        last = descriptions.pop
        descriptions.join(', ') + and_str + last
      else
        descriptions.join(commas)
      end
    end
  end

  def list_names(and_str='and')
    case self.count
      when 0 then ''
      when 1 then self[0].name
      else
      descriptions = self.map(&:name)

      last = descriptions.pop
      descriptions.join(', ') + " #{and_str} " + last
    end
  end
end

class String
  def a
    if self =~ /^[aeiou]/
      "an #{self}"
    else
      "a #{self}"
    end
  end

  def s(n=nil)
    if self =~ /s$/ or self =~ /sh$/
      if n
        "#{n} #{self}"
      else
        self
      end
    else
      if n
        "#{n} #{self}#{n == 1 ? '' : 's'}"
      else
        "#{self}s"
      end
    end
  end

  def sentence
    first, rest = self.slice(0,1), self.slice(1, self.length)
    first.capitalize + rest + '.'
  end

  def tweak_name
    if self.match(/ /)
      self.sub!(/ /, "'")
    end

=begin
    match = self.scan /[fhmpst]/
    if !match.empty?
      swap_i = rand match.length
      
      switch = case match[swap_i]
               when 'f' then 'v'
               when 'h' then ''
               when 'm' then 'n'
               when 'p' then 'b'
               when 's' then 'z'
               when 't' then 'd'
               end
        
        return self.gsub match[swap_i], switch
    end
=end

    if self.match /'/
      if rand < 0.5
        return self.sub /([a-z]')/, '' 
      else
        return self.sub /('[a-z])/, '' 
      end
    elsif md = self.match(/([aeiou])[^aeiou]+([aeiou])/)
      return self.sub md[0], "#{md[1]}'#{md[2]}"
    elsif md = self.match(/([aeiou][aeiou])[aeiou]/)
      return self.sub md[0], md[1]
    end

    if rand < 1.0
      "#{self} #{Markov.animal_name}"
    else
      "#{Markov.animal_name} #{self}"
    end
  end
end

class Object
  def describe(obj=nil)
    if obj
      obj.describe
    else
      self.to_s
    end
  end

  def a(obj)
    obj.describe.a
  end
end

class Numeric
  def thousand
    (self * 1_000).to_i
  end

  def million
    (self * 1_000_000).to_i
  end

  def billion
    (self * 1_000_000_000).to_i
  end

  def trillion
    (self * 1_000_000_000_000).to_i
  end

  def kya
    case self
    when 0...1000
      "#{self} ya"
    when 1000...1_000_000
      "%.3g" % (self / 1000.0) + " kya"
    when 1_000_000...1_000_000_000 
      "%.3g" % (self / 1_000_000.0) + " Mya"
    else 
      "%.3g" % (self / 1_000_000_000.0) + " Gya"
    end
  end
end

module Tickable
  def tick(tick_length)
    @potential_events.each do |event|
      probability = tick_length.to_f / event.frequency
      if rand < probability
        outcome = event.occur self

        if @history[@current_age] == nil
          @history[@current_age] = outcome
        else
          @history[@current_age + 1] = outcome
        end

        compute_potential_events
        break
      end
    end

    if self.respond_to? :subtickables
      subtickables.each do |s|
        s.simulate_history tick_length
      end
    end
  end

  def record_history(outcome)

  end

  def compute_potential_events
    if self.respond_to? :destroyed? and destroyed?
      @potential_events = []
    else
      @potential_events = events.select {|e| e.is_valid? self}
    end
  end

  def describe_history
    timeline = @history.keys.sort
    timeline.map do |time|
      time_ago = @current_age - time
      "#{time_ago.kya}: #{@history[time]}"
    end.join "\n"
  end

  def simulate_history(simulation_years)
    target_age = @current_age + simulation_years

    while @current_age < target_age
      compute_potential_events

      if @potential_events.empty?
        @current_age = target_age
        return
      end

      tick_length = @potential_events.map(&:frequency).min / 100
      @current_age += tick_length
      tick tick_length
    end
  end

  def inflict(event_name)
    event = events.find {|e| e.name == event_name}
    outcome = event.occur self
    @history[@current_age] = outcome
  end
end

def get_started
  $planet = Planet.new
  $location = :space
end

def input_loop
  puts
  case $location
  when :space
    puts $planet.space_view
    puts "\nFly to another star system (f), approach the interesting planet (o), reload (l) or quit (Q)?"

  when :orbit
    puts $planet.orbital_view
    puts "\nFly to another star system (f), explore this planet (e), wait around (w), reload (l) or quit (Q)?"

  end

  print "> "
  input = gets.chomp

  case input
  when /f/
    puts "You fly out into deep space, looking for new adventures amidst the chaos..."
    sleep 1
    $planet = Planet.new
    $location = :space

  when /o/
    puts "You enter a stable orbit around the planet."
    $location = :orbit

  when /e/
    continent_names = $planet.continents.map {|c| c.name.upcase}
    puts "Where would you like to explore? #{continent_names.join(', ')} or OCEANS?"
    print "> "

    input = gets.chomp
    continent = $planet.continents.find {|c| c.name.upcase == input.upcase}
    if continent
      puts "You send a probe down to search for terrestial life. You discover that #{continent.describe_life}."

    elsif input.upcase == 'OCEANS'
      puts "You send a probe down to search for underwater life. You discover that #{$planet.describe_ocean_life}."
    else
      puts "I didn't recognise that location, sorry."
    end

  when /a/
    species_names = $planet.intelligent_species.map {|c| c.name.upcase}
    puts "Which species would you like to investigate? #{species_names.join(', ')}?"
    print "> "

    input = gets.chomp
    species = $planet.intelligent_species.find {|c| c.name.upcase == input.upcase}
    if species
      puts species.describe_history
      puts
      puts species.describe
    else
      puts "I didn't recognise that species, sorry."
    end

  when /h/
    puts $planet.describe_history

  when /w/
    puts "How many millions of years would you like to wait for?"
    print "> "
    years = gets.chomp.to_i
    puts "You orbit the planet for #{years} million years. Time flies..."
    $planet.simulate_history years * 1_000_000

  when /l/
    load "evo.rb"
    puts "\nReloaded code!\n"
  when /Q/
    exit
  end
end
