class Planet
  attr_accessor :has_life, :land_colonised, :has_land_plants, :has_land_animals, :has_land_algae
  attr_reader :history, :continents, :current_age

  include Tickable

  def initialize
    @has_life = false
    @current_age = 0
    @intelligent_species = []
    @gas_neighbours = Random.between 0,5
    @rocky_neighbours = Random.between 0,12
    @history = {0 => "The planet formed from a cloud of dust and rocks."}

    num_regions = Random.between 5, 20
    num_continents = Random.between 1, 7
    continent_sizes = Random.split_up num_regions, num_continents

    @continents = continent_sizes.delete_if {|s| s == 0}.map do |size|
      Continent.new self, size
    end

    simulate_history Random.between 500_000_000, 10_000_000_000
  end

  def intelligent_species(*conditions)
    species = @intelligent_species
    conditions.each do |condition|
      species = species.select do |s|
        case condition
          when :extinct then s.extinct
          when :extant then !s.extinct
          when :land then s.land_dwelling
          when :sea then !s.land_dwelling
          when :industrial then s.tech_level == :industrial
          when :preindustrial then s.tech_level != :industrial
        end
      end
    end

    species
  end

  def destroyed?
    @destroyed
  end

  def hospitable_continents
    @continents.select {|c| c.is_hospitable?}
  end

  def inhospitable_continents
    @continents.select {|c| !c.is_hospitable?}
  end

  def subtickables
    intelligent_species(:extant)
  end

  def describe_age
    ((@current_age / 100_000_000).to_f / 10).to_s + " billion year-old"
  end

  def describe_ocean_life
    if @has_animals
      "the oceans teem with a diverse array of complex lifeforms"
    elsif @has_multicellular_life
      "the oceans are home to single-celled organisms and simple cellular colonies"
    elsif @has_complex_cells
      "complex single-celled organisms can be found in the oceans"
    elsif @has_life
      "very basic single-celled organisms can be found in the oceans"
    else
      "nothing lives in the oceans"
    end
      
  end

  def describe_vegetation
    if @land_colonised
      if inhospitable_continents.empty?
        if @continents.count > 1
          "vegetation covers the entire planet"
        else
          "vegetation covers the entirety of #{@continents[0].name}"
        end
      else
        if @continents.count > 1 and !hospitable_continents.empty?
          "vegetation covers the entirety of #{hospitable_continents.list_names} and some parts of #{inhospitable_continents.list_names}"
        else
          "scattered vegetation can be seen in some hospitable areas"
        end
      end
    elsif @has_land_plants
      "scattered vegetation can be seen in some areas"
    else 
      "the land appears to be completely barren"
    end
  end

  def describe_land_life
    if @land_colonised
      if inhospitable_continents.empty?
        if @continents.count > 1
          "plants and animals can be found on every continent"
        else
          "plants and animals can be found all over #{@continents[0].name}"
        end
      else
        if @continents.count > 1 and !hospitable_continents.empty?
          "plants and animals can be found all over #{hospitable_continents.list_names} and in hospitable regions of #{inhospitable_continents.list_names}"
        else
          "plants and animals can be found in some hospitable areas"
        end
      end
    elsif @has_land_plants and @has_land_animals
      "some plants and animals have begun to colonise the land"
    elsif @has_land_animals
      "some animals have begun to venture onto the land, living off algae-like organisms"
    elsif @has_land_plants
      "vegetation has begun to appear on the land"
    elsif @has_land_algae
      "thin algae-like films can be found on some parts of the land"
    else 
      "the land is completely barren"
    end
  end

  def describe_life
    descriptions = []

    if !@has_life
      return "The planet is completely barren."
    end

    descriptions << describe_ocean_life
    descriptions << describe_land_life

    descriptions.describe(", ", ", and ").sentence
  end

  def describe
    if !@destroyed
      "A #{describe_age} planet with #{'continent'.s @continents.count}: #{@continents.describe}. #{describe_life}\n\n#{@intelligent_species.describe("\n\n")}"
    else
      if @matrioshka
        "A ring of vast artificial structures, providing computational power for an AI civilisation."
      else
        "A belt of asteroids and debris, the remains of a destroyed planet."
      end
    end
  end

  def space_view
    "This star system contains #{@gas_neighbours} large gaseous planets and #{@rocky_neighbours + 1} small rocky planets. One of the rocky planets lies in the star's habitable region, and has an atmosphere#{@has_land_plants ? ', oceans, and evidence of surface vegetation':' and oceans'}."
  end

  def orbital_view
    "This #{describe_age} planet has #{'continent'.s @continents.count}: #{@continents.describe}. #{describe_vegetation.sentence}"
  end

  # special events

  def life_emerges
    @has_life = true
    "Simple cells appeared."
  end

  def complex_cells_emerge
    @has_complex_cells = true
    "Eukaryotic cells appeared."
  end

  def multicellular_life_emerges
    @has_multicellular_life = true
    "Multicellular life appeared, in the form of simple cell colonies."
  end

  def land_algae
    @has_land_algae = true
    "Single-celled organisms began to colonise the land."
  end

  def cambrian_explosion
    @has_animals = true
    "Large, complex multicellular organisms appeared in the oceans." 
  end

  def land_animals
    @has_land_animals = true
    if @has_land_plants
      "Animals began to walk on the land."
    else
      "Animals began to walk on the land, subsisting on algae-like organisms."
    end
  end

  def land_plants
    @has_land_plants = true
    "Plants began to appear on the land."
  end

  def carboniferous
    @land_colonised = true
    "Plants and animals had colonised most of the planet's surface."
  end

  def intelligent_life
    new_kids_on_the_block = Species.new(true, self)
    @intelligent_species << new_kids_on_the_block
    "On the continent of #{new_kids_on_the_block.continent.name}, a species calling themselves the '#{new_kids_on_the_block.species_name}' developed the capability for speech, tool-making and abstract thought."
  end
  
  def intelligent_sea_life
    new_kids_on_the_block = Species.new(false, self) 
    @intelligent_species << new_kids_on_the_block
    "An ocean-dwelling species calling themselves the '#{new_kids_on_the_block.species_name}' developed the capability for speech and abstract thought."
  end

  def big_asteroid
    if @has_animals
      extinction_rate = Random.between 5,99

      outcome = "A huge asteroid collided with the planet's surface, wiping out #{extinction_rate}% of species." 

      if extinction_rate > 95 and @has_land_animals
        outcome += " All complex life on land was wiped out."
        @has_land_animals = false
        @has_land_plants = false
        @land_colonised = false
        @has_intelligent_life = false
      end

      intelligent_species(:extant).each do |species|
        if rand(100) < extinction_rate
          outcome += " The #{species.species_name} were wiped out."
          species.wipeout
          species.inflict :asteroid_wipeout
        else
          outcome += " The #{species.species_name} were nearly wiped out, but a few scattered individuals managed to survive"
          outcome += (species.tech_level == :primitive) ? '.' : ', though they were forced back to a stone-age level of technology.'
          species.near_wipeout
          species.inflict :asteroid_near_wipeout
        end
      end

      outcome
    else
      "A huge asteroid collided with the planet's surface."
    end
  end

  def mega_asteroid
    @destroyed = true
    "A moon-sized asteroid collided with the planet, completely disintegrating it."
  end

  def matrioshka_meltdown
    @destroyed = true
    @matrioshka = true
    "An exponentially self-improving machine civilisation emerged, and tore the planet apart to build more computational power."
  end

  def events
    [
     Event.new(:life_emerges, 1.5.billion, '!@has_life'),
     Event.new(:land_algae, 1.billion, '@has_life and !@has_land_algae'),
     Event.new(:complex_cells_emerge, 2.billion, '@has_life and !@has_complex_cells'),
     Event.new(:multicellular_life_emerges, 600.million, '@has_complex_cells and !@has_multicellular_life'),
     Event.new(:cambrian_explosion, 600.million, '@has_multicellular_life and !@has_animals'),
     Event.new(:land_animals, 50.million, '@has_animals and @has_land_algae and !@has_land_animals'),
     Event.new(:land_plants, 50.million, '@has_animals and @has_land_algae and !@has_land_plants'),
     Event.new(:carboniferous, 10.million, '@has_land_animals and @has_land_plants and !@land_colonised'),
     Event.new(:intelligent_life, 800.million, '@land_colonised and intelligent_species(:extant, :land, :industrial).count == 0'),
     Event.new(:intelligent_sea_life, 3.billion, '@has_animals'),
     Event.new(:big_asteroid, 1.billion),
     Event.new(:mega_asteroid, 50.billion),
     Event.new(:matrioshka_meltdown, nil, 'false')
    ]
  end
end
