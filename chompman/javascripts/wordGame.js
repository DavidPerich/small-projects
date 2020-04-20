const NUMBER_OF_FISH = 5;
var $guesses = $("#guesses");
var $letters = $("#letters");
var $resultBox = $("#game-result");
var $message = $("#message");


var randomWord = (function () {
  var words = [
    "add", "after", "again", "age", "all", "am", "an", "and", "any", "apart", "apple", "are", "arm", "as", "ask", "at", "ate", "baby", "bad", "bag", "bake", "ball", "banana", "band", "bang", "bar", "bark", "bask", "bat", "bay", "be", "beat", "bed", "bee", "beef", "been", "beep", "beet", "beg", "being", "bell", "belt", "bent", "best", "bid", "big", "bike", "bill", "bird", "birth", "bit", "black", "blew", "block", "blue", "boat", "bold", "bone", "book", "born", "bow", "bowl", "box", "boy", "brag", "bring", "brook", "brother", "brown", "bug", "bump", "bun", "bus", "bush", "but", "by", "bye", "cage", "cake", "call", "came", "can", "cane", "cap", "car", "card", "cart", "case", "cat", "chain", "chair", "chalk", "chat", "chin", "chop", "clam", "clan", "clap", "class", "claw", "clay", "clean", "cloud", "clover", "club", "coat", "cold", "come", "cone", "cook", "cool", "corn", "could", "cow", "cram", "crayon", "crew", "crib", "crow", "crowd", "crown", "cry", "cub", "cube", "cup", "cut", "dad", "dam", "dark", "date", "day", "deal", "deep", "deer", "den", "dent", "desk", "dew", "did", "die", "dig", "dike", "dime", "dine", "dip", "dirt", "dog", "doll", "door", "dot", "draw", "dress", "drink", "drop", "dry", "duck", "dug", "dull", "dump", "dust", "each", "east", "easy", "eat", "egg", "eight", "eleven", "end", "every", "fake", "fall", "fan", "fang", "far", "farther", "fast", "fate", "father", "feet", "fell", "few", "field", "fig", "fill", "fin", "find", "fine", "first", "fit", "five", "flag", "flat", "flew", "flower", "fog", "fold", "fool", "foot", "fork", "fort", "four", "fox", "fray", "free", "fresh", "frog", "from", "fry", "fun", "gag", "game", "gang", "gate", "gave", "get", "gift", "girl", "give", "glad", "go", "going", "golf", "gone", "got", "grape", "grass", "gray", "green", "grew", "grit", "gull", "gust", "gut", "had", "hall", "ham", "hand", "hang", "happy", "hard", "harm", "has", "hate", "have", "hay", "he", "heat", "heavy", "help", "hen", "her", "here", "hi", "hid", "hide", "hike", "hill", "him", "hind", "hint", "hip", "his", "hit", "hoe", "hold", "home", "hop", "hope", "horn", "hot", "how", "hug", "hump", "hush", "hut", "if", "ill", "in", "inside", "into", "is", "it", "jam", "jar", "jaw", "jeep", "jet", "job", "juice","jump","just","keep","keg","kind","king","kit","kite","know","lake","lamp","land","last","late","law","lawn","led","leg","lent","let","lie","like","lime","line","lion","lip","live","look","love","low","luck","lump","mad","made","maid","make","mall","man","many","map","mask","mat","mate","may","me","meal","meat","meet","men","met","mice","milk","mind","mine","mint","mit","mix","mob","mold","mom","moon","mop","more","morning","mother","mow","much","mug","mule","must","my","nail","name","nap","neat","neck","nest","net","never","new","next","nine","noon","nose","not","note","now","nut","odd","of","old","once","one","open","or","orange","other","ours","over","ox","pad","page","pain","pants", "part", "pat", "pave", "paw", "pay", "pear", "peep", "peg", "pen", "pencil", "pest", "pet", "pets", "pick", "pie", "pig", "pike", "pin", "pink", "pit", "plan", "plane", "plant", "play", "plod", "pond", "poor", "pop", "pot", "pox", "pray", "pretty", "print", "pump", "punch", "pup", "purple", "put", "rag", "rage", "rain", "ram", "ran", "rang", "rank", "rat", "rate", "raw", "ray", "read", "red", "rest", "rid", "ride", "river", "road", "rob", "rock", "rode", "room", "rope", "rot", "round", "rub", "rubber", "rug", "run", "rust", "rut", "sad", "said", "sail", "sale", "same", "sank", "sap", "sat", "save", "saw", "say", "seat", "see", "seed", "seen", "seep", "sell", "send", "set", "seven", "shake", "shall", "shape", "she", "ship", "shirt", "shoes", "shop", "show", "shut", "sick", "side", "sink", "sip", "sister", "sit", "six", "size", "sled", "sleep", "slip", "slow", "smell", "snail", "snap", "snore", "snow", "snug", "so", "sob", "soda", "sofa", "sold", "some", "soon", "spit", "spoon", "stamp", "star", "start", "stay", "step", "stew", "still", "stir", "stone", "stool", "stop", "stove", "stow", "straw", "stray", "string", "such", "summer", "sun", "swing", "table", "tag", "tail", "take", "tale", "tall", "tan", "tank", "tap", "tar", "task", "team", "tell", "ten", "tent", "test", "thank", "their", "them", "then",  " there", "these","they","thick","thing","think","third","this","those","three","tie","time","tip","today","toe","told","took","top","tow","toy","train","tree","trip","truck","trust","try","tub","tube","tug","twelve","two","under","up","upon","us","use","used","van","very","vest","vote","wag","wait","walk","wall","want","was","water","way","we","well","were","west","wet","when","which","white","who","wide","wig","will","win","wing","winter","with","woman","women","wow","yam","yell","zero","zone","zoo"];

    return function() {
      var rand = Math.floor(Math.random() * words.length);
      return words.splice(rand, 1)[0];
    };
  })();


function animateElement($e) {
  $e.delay(200).animate({
    left: $("body").width() / 2 - $($e).width() / 2,
    top: 350
  }, 1000);

  return $e;
}

var NewGame = {
  init: function() {
    this.word = randomWord().split("");
    this.guesses = [];
    this.incorrectGuesses = 0;
    this.correctGuesses = 0;
    this.resetScreen();
    this.bindKeyPress();
    this.addLetters();
    console.log(this.word);

    return this;
  },

  isInvalidGuess: function(guess) {
    if (guess.length > 1 || !guess.match(/[a-z]/i)) {return true;}
    return this.guesses.includes(guess);
  },

  isIncorrectGuess: function(guess) {
    return this.word.indexOf(guess) === -1;
  },

  outOfGuesses: function() {
    return this.incorrectGuesses === NUMBER_OF_FISH;
  },

  incorrectGuessAction: function(guess) {
    this.eatFish();
    this.incorrectGuesses += 1;
    $guesses.append("<span>" + guess + "</span>");
    document.querySelector('#oops').play();
    },

  correctGuessAction: function(guess) {
    for (let i = 0; i < this.word.length; i += 1) {
      if (this.word[i] === guess) {
        $letters.children("span").eq(i).text(guess)
        document.querySelector('#yes').play();
        this.correctGuesses += 1;
      }
    }
  },

  wordComplete: function() {
    return this.correctGuesses === this.word.length;
  },

  eatFish: function () {
      animateElement($(".fish div").eq(this.incorrectGuesses)).fadeOut(200);
      document.querySelector('#chomp').play();
    },

  showResultMessage: function(message) {
    $message.text(message);
    $resultBox.show().css({
      display: "block",
    });
  },

  addLetters: function() {
    for (let i = 0; i < this.word.length; i += 1) {
      $letters.append("<span>")
    }
  },

  success: function() {
    $("body, main").css({
      background: "green"
    });

    document.querySelector('#youWon').play();
    this.showResultMessage("Congratulations you beat the chompman")
  },

  failure: function() {
    $("body").css({
      background: "#780E24"
    });

    document.querySelector('#ohNo').play();
    this.showResultMessage("The chompman ate all the fish. You lose")
  },

  resetScreen: function() {
    $("html *").removeAttr("style");
    $(".game-box span").remove();
  },

  bindKeyPress: function () {
    $("body").keypress(this.processGuess.bind(this))
  },

  processGuess: function processGuess(e) {
    var guess = e.key.toLowerCase();

    if (this.isInvalidGuess(guess)) {
      alert("please select a valid letter")
      return;
    }

    if (this.isIncorrectGuess(guess)) {
      this.incorrectGuessAction(guess);

      if (this.outOfGuesses()) {
        this.failure();
        $("body").off("keypress")
      }
      return;
    }

    this.correctGuessAction(guess);

    if (this.wordComplete()) {
      this.success();
      $("body").off("keypress")
    }
  },
};

$(function () {
  var game =  Object.create(NewGame).init();

  $("#game-result a").click(function (e) {
    e.preventDefault();
    game =  Object.create(NewGame).init();
   });
});

