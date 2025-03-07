enum ZodiacSign {
  aries('Aries'),
  taurus('Taurus'),
  gemini('Gemini'),
  cancer('Cancer'),
  leo('Leo'),
  virgo('Virgo'),
  libra('Libra'),
  scorpio('Scorpio'),
  sagittarius('Sagittarius'),
  capricorn('Capricorn'),
  aquarius('Aquarius'),
  pisces('Pisces');

  final String display;
  const ZodiacSign(this.display);
}

enum EducationLevel {
  highSchool('High School'),
  inCollegeUni('In College/Uni'),
  inGradSchool('In Grad School'),
  tradeSchool('Trade School'),
  higherCertificate('Higher Certificate'),
  bachelors('Bachelors'),
  honours('Honours'),
  masters('Masters'),
  phd('PhD');

  final String display;
  const EducationLevel(this.display);
}

enum FamilyPlanOption {
  notSureYet('Not sure yet'),
  wantChildren('I want children'),
  dontWantChildren("I don't want children"),
  haveAndWantMore('I have children and want more'),
  haveAndDontWantMore("I have children and don't want more");

  final String display;
  const FamilyPlanOption(this.display);
}

enum CommunicationStyle {
  bigTimeTexter('Big time texter'),
  phoneCaller('Phone caller'),
  videoChatter('Video chatter'),
  badTexter('Bad texter'),
  betterInPerson('Better in person');

  final String display;
  const CommunicationStyle(this.display);
}

enum LoveLanguage {
  thoughtfulGestures('Thoughtful gestures'),
  gifts('Gifts'),
  touch('Touch'),
  compliments('Compliments'),
  qualityTime('Quality time');

  final String display;
  const LoveLanguage(this.display);
}

enum DrinkingHabit {
  notForMe('Not for me'),
  sober('Sober'),
  soberCurious('Sober curious'),
  specialOccasions('On special occasions'),
  sociallySomeWeekends('Socially on some weekends'),
  sociallyMostWeekends('Socially on most weekends'),
  mostNights('Most nights');

  final String display;
  const DrinkingHabit(this.display);
}

enum SmokingHabit {
  socialSmoker('Social smoker'),
  smokerWhenDrinking('Smoker when drinking'),
  nonSmoker('Non-smoker'),
  smoker('Smoker'),
  tryingToQuit('Trying to quit');

  final String display;
  const SmokingHabit(this.display);
}

enum WorkoutHabit {
  everyday('Everyday'),
  often('Often'),
  sometimes('Sometimes'),
  never('Never');

  final String display;
  const WorkoutHabit(this.display);
}

enum DietaryPreference {
  vegan('Vegan'),
  vegetarian('Vegetarian'),
  pescatarian('Pescatarian'),
  kosher('Kosher'),
  halal('Halal'),
  carnivore('Carnivore'),
  omnivore('Omnivore'),
  other('Other');

  final String display;
  const DietaryPreference(this.display);
}

enum SleepingHabit {
  earlyBird('Early bird'),
  nightOwl('Night owl'),
  inSpectrum('In a spectrum');

  final String display;
  const SleepingHabit(this.display);
}

enum PetOption {
  dog('Dog'),
  cat('Cat'),
  reptile('Reptile'),
  amphibian('Amphibian'),
  bird('Bird'),
  fish('Fish'),
  dontHaveButLove("Don't have but love"),
  turtle('Turtle'),
  hamster('Hamster'),
  rabbit('Rabbit'),
  other('Other'),
  petFree('Pet-free'),
  allThePets('All the pets'),
  wantAPet('Want a pet'),
  allergicToPets('Allergic to pets');

  final String display;
  const PetOption(this.display);
}

// Note: Add Tinder interests here once we have the list
enum Interest {
  // TODO: Add all Tinder interests
  placeholder('Placeholder');

  final String display;
  const Interest(this.display);
}

enum SexualityOption {
  straight('Straight'),
  gay('Gay'),
  lesbian('Lesbian'),
  bisexual('Bisexual'),
  pansexual('Pansexual'),
  asexual('Asexual'),
  demisexual('Demisexual'),
  queer('Queer'),
  questioning('Questioning'),
  other('Other');

  final String display;
  const SexualityOption(this.display);
}
