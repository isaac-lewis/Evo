class Species
  attr_reader :species_name, :continent, :extinct, :tech_level, :land_dwelling

  include Tickable

  def initialize(land_dwelling, planet)
    @land_dwelling = land_dwelling
    @tech_level = :primitive
    assign_random_name
    assign_random_social_organisation
    assign_random_hobbies

    @current_age = 0
    @planet = planet

    if land_dwelling
      assign_continent(planet)
      @history = {0 => "We first arose on the continent of #{@continent.name}."}
    else
      @history = {0 => "We first arose in the oceans."}
    end
  end

  def destroyed?
    @extinct or planet.destroyed?
  end

  def planet
    @planet
  end

  def name
    @species_name
  end

  def hospitable_home
    @continent.hospitality > 0.3
  end

  def assign_continent(planet)
    possible_continents = planet.continents.sort_by(&:hospitality).reverse
    possible_continents.each do |c|
      if rand < c.hospitality * 0.8
        @continent = c
      end
    end

    @continent = possible_continents.sample
  end

  def assign_random_social_organisation
    @social_organisation = if @land_dwelling
      [:bands, :solitary, :villages, :eusocial].sample
    else
      [:pods, :solitary, :unified, :complex, :eusocial].sample
    end
  end

  def assign_random_name
    @individual_name = Markov.animal_name
    # cause sometimes you need an extra name
    @individual_name += ' ' + Markov.animal_name if rand < 0.15
    @species_name = @individual_name.s
  end

  def assign_random_hobbies
    possible_hobbies = ["thinking about mathematics", "meditating", "praying", "consuming trance-inducing plants", "dancing", "performing acrobatics", "contemplating the universe", "wallowing in self-pity", "wondering if they live in a simulation"]

    if @land_dwelling 
      possible_hobbies += ["rolling boulders up hills", "banging rocks together", "painting on cave walls","basket-weaving","making simple jewellery","playing with fire","setting fire to things","painting themselves","wrestling","playing in rivers","torturing small animals","trying to build bigger huts","making simple musical instruments","stargazing","looking at clouds"]
    end

    if @social_organisation != :solitary
      possible_hobbies += ["reciting epic poems", "telling jokes", "hosting elaborate theatrical performances", "holding shamanic religous ceremonies", "organising athletic competitions", "fighting", "having ritualistic sex", "chanting in groups","playing sports","holding grudges","gossiping","being really passive-aggressive","thinking up witty comebacks","making friends","organising romantic evenings for one another","feeling vaguely guilty about things","debating"]
    end

    if @social_organisation == :eusocial
      possible_hobbies = ["defending the queen","thinking about the queen","self-sacrifice","tending the eggs","fighting intruders","taking care of the larvae"]
    end

    @hobbies = []
    2.times {@hobbies << possible_hobbies.sample}
    @hobbies.uniq!
  end

  def describe
    if @extinct
      return @ruins_msg if @ruins_msg 
      if @land_dwelling
        return "There is scattered evidence of an extinct intelligent species which once inhabited the continent of #{@continent.name}."
      else
        return "There is scattered evidence of an extinct intelligent species which once inhabited the oceans."
      end

    elsif @land_dwelling
      desc = "An intelligent species known as the '#{@species_name}' "
      desc += case @tech_level
              when :primitive then "can be found on the continent of #{@continent.name}, gathering plants and hunting animals with stone tools."
              when :agricultural then " can be found all over the planet, living in settled farming communities."
              when :industrial then "can be found all over the planet, living in sprawling, crowded cities."
              when :enlightened then "can be found all over the planet, living in beautiful, spacious cities."
              end
    else
      desc = "An intelligent species known as the '#{@species_name}' can be found in the oceans; lacking any form of technology, they have instead developed a complex oral culture."
    end

    if !@land_dwelling || @tech_level == :primitive
      desc += case @social_organisation
              when :bands then " They roam the land in small bands, and entertain one another by #{@hobbies.describe}."
              when :solitary then " They mostly live alone and occupy themselves by #{@hobbies.describe}."
              when :villages then " They live together in clusters of crude huts, and pass the time in between hunts by #{@hobbies.describe}."
              when :pods then " They roam the seas in large pods, and entertain one another by #{@hobbies.describe}."
              when :unified then " They long ago forsook conflict and organised themselves into a single unified civilisation, and now devote most of their time to #{@hobbies.describe}."
              when :complex then " They form elaborate social organisations which outsiders cannot easily understand, and devote most of their time to #{@hobbies.describe}."
              when :eusocial then " They live together in nests containing thousands of individuals, and mainly concern themselves with #{@hobbies.describe}."
              end
    else
      desc += case @tech_level
              when :agricultural then " When not busy tending crops or looking after the animals, they pass their time by #{@hobbies.describe}."
              when :industrial then " When not busy working or commuting, they spend their spare time #{@hobbies.describe}."
              when :enlightened then " They now devote their lives to what they regard as the highest arts of civilisation: #{@hobbies.describe}."
              end
    end

    return desc
  end

  def agricultural_revolution
    @tech_level = :agricultural

    "The #{@species_name} discovered the arts of agriculture and animal husbandry, leading to a population exlosion and enabling the rise of a settled civilisation."
  end

  def industrial_revolution
    @tech_level = :industrial
    "The #{@species_name} learned how to harness steam power, leading to a rapid increase in economic and technological progress."
  end

  def singularity
    @extinct = true
    planet.inflict :matrioshka_meltdown
    "#{@individual_name.capitalize} scientists created a self-improving artificial intelligence. The AI transformed the planet into a ring of giant solar-powered computers, destroying all life in the process."
  end

  def nuclear_war
    case rand
    when (0...0.1)
      @extinct = true
      @ruins_msg = "The empty, ruined cities of a technologically advanced civilisation can be seen scattered around the planet."

      "The #{@species_name} destroyed themselves in a nuclear war."
    when (0.1...0.4)
      near_wipeout
      "The #{@species_name} almost destroyed themselves in a nuclear war. A few scattered individuals managed to survive, though they were forced back to a stone age level of technology."
    when (0.4...0.8)
      @tech_level = :primitive
      "The #{@species_name} almost destroyed themselves in a nuclear war. A sizable population managed to survive, though they were forced back to a stone age level of technology."
    when (0.8..1.0)
      @tech_level = :agricultural
      "The #{@species_name} almost destroyed themselves in a nuclear war. Some pockets of civilisation survived relatively unscathed, though they were forced back to a pre-industrial level of technology."
    end
  end

  def enlightenment
    @tech_level = :enlightened
    "The #{@species_name} built a global civilisation, and vowed to renounce all war and to live in harmony with nature."
  end

  def bad_climate
    @almost_dead = true
    "The #{@continent.describe_temperature}, #{@continent.describe_precipitation} climate of #{@continent.name} forced the #{@individual_name} population down to just a few thousand individuals."
  end

  def near_wipeout
    @almost_dead = true
    @tech_level = :primitive
  end

  def wipeout
    @extinct = true
  end

  def bad_luck
    @extinct = true
    "With their dwindling numbers, it only took a few bad years to wipe out the #{@species_name} for good."
  end

  def regrowth
    @almost_dead = false
    "The #{@species_name} population regrew to a healthy level."
  end

  def evolution
    old_name = @species_name
    @individual_name = @individual_name.tweak_name
    @species_name = @individual_name.s

    change = ['taller','shorter','bigger','smaller','kinder','more violent','gentler','hairier','more beautiful','uglier','smarter','more stupid','more aggressive','more solitary','more social','lighter-skinned','darker-skinned'].sample

    "Evolution made the creatures known as the #{old_name} noticably #{change}, and they began calling themselves the '#{@species_name}'."
  end

  def genocide
    victims = planet.intelligent_species(:extant, :land, :preindustrial).sample
    victims.near_wipeout
    "The #{@species_name}' insatiable demand for natural resources has massively damaged the ecosystems of #{victims.continent.name}, pushing the #{victims.species_name} into near extinction."
  end

  def asteroid_wipeout
    wipeout
    "A huge asteroid fell from the skies, wiping out the #{@species_name}."
  end

  def asteroid_near_wipeout
    "A huge asteroid fell from the skies, almost wiping out the #{@species_name}. A few scattered individuals managed to survive."
  end

  def events
    [
     Event.new(:bad_luck, 50.thousand, "@almost_dead "),
     Event.new(:regrowth, 50.thousand, "@almost_dead "),
     Event.new(:bad_climate, 500.thousand, '@land_dwelling and @tech_level == :primitive  and !@almost_dead and !hospitable_home'),
     Event.new(:agricultural_revolution, 100.thousand, '@land_dwelling and @tech_level == :primitive  and !@almost_dead'),
     Event.new(:industrial_revolution, 10.thousand, '@land_dwelling and @tech_level == :agricultural '),
     Event.new(:nuclear_war, 300, '@land_dwelling and @tech_level == :industrial '),
     Event.new(:singularity, 300, '@land_dwelling and @tech_level == :industrial '),
     Event.new(:enlightenment, 3000, '@land_dwelling and @tech_level == :industrial '),
     Event.new(:genocide, 200, '@land_dwelling and @tech_level == :industrial  and planet.intelligent_species(:extant, :land, :preindustrial).count >= 1'),


     Event.new(:asteroid_wipeout, nil, 'false'),
     Event.new(:asteroid_near_wipeout, nil, 'false')
     
     # Event.new(:evolution, 100.million, '!@extinct')
    ]
  end
end
