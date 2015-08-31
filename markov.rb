class Markov
  AnimalNames = ["squirrel", "parrot", "lion", "tiger", "ox", "crocodile",
"elephant", "monkey", "dog", "mandrill", "parakeet", "seal", "fish", "moth",
"bumblebee", "chimpanzee", "butterfly", "gorilla", "cat", "mouse", "rat",
"hamster", "guinea pig", "hound", "orangutang", "snake", "worm", "ant",
"spider", "tarantula", "pikachu", "mudkip", "wolf", "fox", "dinosaur",
"lizard", "iguana", "dingo", "pig", "wild boar", "badger", "otter", "carp",
"manatee", "narwhale", "cow", "antelope", "zebra", "buffalo", "bison",
"chinchilla", "rabbit", "ostrich", "chicken", "bear", "horse", "donkey",
"ape", "caterpillar", "tyrannosaurus", "mammoth", "cod", "sealion", "bat",
"ladybird", "macaque", "kobold", "goblin", "hobbit", "stegosaurus", "rhinocerours", "hippopotamus", "alligator", "human", "eel", "jellyfish", "wombat", "kangaroo", "mole", "shrew", "aardvark", "hyrax", "dugong", "sea cow", "armadillow", "anteater", "treeshrew", "lemur", "chipmunk", "gopher", "hare", "hedgehog", "whale", "dolphin", "porpoise", "weasel", "giant panda", "red panda", "skunk", "giraffe", "walrus", "raccoon", "wolverine", "hyena", "civet", "dormouse", "turtle", "tortoise", "python", "cobra", "dragon", "albatross",
"aardvark","albatross","alligator","alpaca","anaconda","angelfish","anglerfish","ant","antlion","anteater","antelope","ape","aphid","armadillo","asp","ass","baboon","badger","bandicoot","barnacle","basilisk","barracuda","bass","bat","bear","beaver","bee","beetle","bird","bison","blackbird","boa","bobcat","bobolink","booby","bovid","buffalo","bug","bulldog","butterfly","buzzard","camel","canid","cardinal","caribou","carp","cat","caterpillar","catfish","centipede","cephalopod","chameleon","cheetah","chickadee","chicken","chihuahua","chimpanzee","chinchilla","chipmunk","clam","clownfish","cobra","cockroach","cod","collie","condor","constrictor","coral","cougar","coyote","cow","crab","crane","crawdad","crayfish","cricket","crocodile","crow","cuckoo","damselfly","deer","dingo","dinosaur","dog","dolphin","donkey","dormouse","dove","dragonfly","duck","eagle","earthworm","earwig","eel","egret","elephant","elk","emu","ermine","falcon","ferret","finch","firefly","fish","flamingo","flea","fly","flyingfish","fowl","fox","frog","fruitbat","gazelle","gecko","gerbil","gibbon","guanaco","guineafowl","giraffe","goat","goldfinch","goldfish","goose","gopher","gorilla","grasshopper","greyhound","grouse","gull","guppy","haddock","halibut","hamster","hare","harrier","hawk","hedgehog","heron","herring","hippopotamus","hookworm","hornet","horse","hound","human","hummingbird","husky","hyena","iguana","impala","insect","jackal","jaguar","jay","jellyfish","kangaroo","kingfisher","kite","kiwi","koala","koi","krill","ladybug","lamprey","lark","leech","lemming","lemur","leopard","leopon","liger","lion","lizard","llama","lobster","locust","loon","louse","lungfish","lynx","macaw","mackerel","magpie","mammal","marlin","marmoset","marmot","marsupial","marten","mastiff","meadowlark","meerkat","mink","minnow","mite","mockingbird","mole","mollusk","mongoose","monkey","moose","mosquito","moth","mountain goat","mouse","mule","muskox","mussel","narwhal","newt",	"nightingale","ocelot","octopus","opossum","orangutan","orca","ostrich","otter","owl","ox","oyster","panda","panther","parakeet","parrot","parrotfish","partridge","peacock","peafowl","pekingese","pelican","penguin","perch","pheasant","pig","pigeon","pike","piranha","planarian","platypus","poodle","porcupine","porpoise","possum","prawn","primate","puffin","puma","python","quail","rabbit","raccoon","rat","rattlesnake","raven","reindeer","rhinoceros","roadrunner","robin","rodent","rook","roundworm","sailfish","salamander","salmon","sawfish","scallop","scorpion","seahorse","setter","shark","sheep","sheepdog","shrew","shrimp","silkworm","silverfish","skink","skunk","sloth","slug","smelt","snail","snake","snipe","sole","spaniel","spider","spoonbill","squid","squirrel","starfish","stoat","stork","sturgeon","swallow","swan","swift","swordfish","swordtail","tahr","takin","tapeworm","tapir","tarantula","termite","tern","terrier","thrush","tiger","tigon","toad","tortoise","toucan","trout","tuna","turkey","turtle","tyrannosaurus","urial","viper","vole","vulture","wallaby","walrus","wasp","warbler","weasel","whale","whitefish","wildebeest","wildfowl","wolf","wolverine","wombat","woodpecker","worm","wren","yak","zebra"]

  attr_reader :hash

  def initialize(words_list)
    @hash = {:start => []}
    words_list.each do |word|
      character_pairs = word.downcase.character_pairs
      character_pairs.each_with_index do
        |pair, i|
        @hash[:start] << pair if i == 0
        if @hash[pair]
          @hash[pair] << character_pairs[i + 1] 
        else
          @hash[pair] = [character_pairs[i + 1]]
        end
      end
    end
  end

  def word
    pair = @hash[:start].sample
    word = ''
    while pair
      word += pair
      pair = @hash[pair].sample
    end
    if word.length > 3 and word.length < 16 then word
    else self.word
    end
  end

  def self.animal_name
    @markov = Markov.new AnimalNames if @markov.nil?
    @markov.word
  end
end

class String
  def character_pairs
    if length <= 2 then [self]
    else [self[0..1]] + self[2..length].character_pairs
    end
  end

  def capitalize_words
    words = self.split ' '
    words.map! {|word| word.capitalize}
    words.join ' '
  end
end
