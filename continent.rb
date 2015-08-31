class Continent
  attr_reader :name, :planet

  @@names = ["Laurasia","Gondwana","Cimmeria","Kalaharia","Avalonia","Atlantica","Mu","Siberia","Urasia","Zealandia","Aurora","Pangaea","Ur","Europa","Hyperboria","Africana","Asiana","Nazca","Indus","Scotia","Australis","Beringia","Venedian","Rodinia","Vaalbara","Amasia","Lemuria","Avalon","Nena","Nineveh","Arctica","Pannotia","Doggerland","Thule","Basilia","Shambhala","Sahra","Tibesti","Onogoro","California","Hufaidh","Argyre","Antillia","Maui","Lantau","Lamma","Zanzibar","Maluku","Samarqand","Parthia","Assyria","Byzantia","Bactriana","Ariana","Tabaristan","Asorestan","Zabulistan","Deccan","Aman","Eriador","Thar","Kashmir","Jammu","Andaman","Indomalaya","Arcadia","Pella","Goa","Magahda","Kuru","Panchala","Surasena","Sundarban","Brahmaputra","Chin"]

  @@free_names = @@names.clone

  def initialize(planet,size)
    @planet = planet
    @regions = [] 
    size.times {@regions << Region.new}
    @mean_temperature = Random.between -10, 50
    @mean_precipitation = Random.between 0, 50

    assign_name
  end

  def assign_name
    @@free_names = @@names.clone if @@free_names.empty?
    @@free_names.shuffle!
    @name = @@free_names.pop
  end

  def is_hospitable?
    hospitality >= 0.5
  end

  def hospitality
    temp_score = if @mean_temperature > 10
                   if @mean_temperature < 30
                     1
                   else
                     1 + ((30 - @mean_temperature) / 20.0)
                   end
                 else
                   1 + ((@mean_temperature - 10) / 20.0)
                 end

    prec_score = if @mean_precipitation > 20
                   1
                 else
                   1 + ((@mean_precipitation - 20) / 20.0)
                 end

    temp_score * prec_score
  end

  def describe_temperature
    case @mean_temperature
    when -270...0 then 'frozen'
    when 0...10 then 'cold'
    when 10...20 then 'mild'
    when 20...30 then 'warm'
    when 30...40 then 'hot'
    else 'scorching'
    end
  end

  def describe_precipitation
    case @mean_precipitation
    when 0...10 then 'desert'
    when 10...20 then 'dry'
    when 20...30
      case @mean_temperature
      when -270...0 then 'icy'
      when 0...20 then 'misty'
      when 20...40 then 'cloudy'
      else 'cloudy'
      end

    when 30...40
      case @mean_temperature
      when -270...0 then 'snowy'
      when 0...10 then 'misty'
      when 10...30 then 'drizzly'
      else 'humid'
      end

    else
      case @mean_temperature
      when -270...0 then 'snowy'
      when 0...20 then 'rainy'
      when 20...40 then 'wet'
      else 'stormy'
      end
    end
  end

  def describe_size
    case @regions.count
      when 1 then 
      "the #{describe_temperature}, #{describe_precipitation} island continent of #{@name}"
      when 2..3 then 
      "the small, #{describe_temperature}, #{describe_precipitation} continent of #{@name}"
      when 4..7 then 
      "the large, #{describe_temperature}, #{describe_precipitation} continent of #{@name}"
      else 
      "the #{describe_temperature}, #{describe_precipitation} supercontinent of #{@name}"
    end
  end

  def describe_life
    if @planet.land_colonised
      if is_hospitable?
        "plants and animals can be found all over #{@name}"
      else
        "plants and animals can be found in some hospitable areas of #{@name}"
      end
    elsif @planet.has_land_plants and @planet.has_land_animals
      "some animals have begun to venture onto the shores of #{@name}, living off the scanty vegetation"
    elsif @planet.has_land_animals
      "some animals have begun to venture onto the shores of #{@name}, living off algae-like organisms"
    elsif @planet.has_land_plants
      "vegetation can be found in some areas near the shores of #{@name}"
    elsif @planet.has_land_algae
      "thin algae-like films can be found in some areas of #{@name}"
    else 
      "the continent of #{@name} is completely barren"
    end
  end

  def describe
    describe_size
  end
end
