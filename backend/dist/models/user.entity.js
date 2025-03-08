"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = exports.LoveLanguage = exports.SleepingHabit = exports.DietaryPreference = exports.WorkoutHabit = exports.DrinkingHabit = exports.SmokingHabit = exports.Interest = exports.CommunicationStyle = exports.EducationLevel = exports.GenderOption = void 0;
const typeorm_1 = require("typeorm");
var GenderOption;
(function (GenderOption) {
    GenderOption["MAN"] = "man";
    GenderOption["WOMAN"] = "woman";
    GenderOption["BEYOND_BINARY"] = "beyondBinary";
})(GenderOption || (exports.GenderOption = GenderOption = {}));
var EducationLevel;
(function (EducationLevel) {
    EducationLevel["HIGH_SCHOOL"] = "highSchool";
    EducationLevel["HIGHER_CERTIFICATE"] = "higherCertificate";
    EducationLevel["BACHELORS"] = "bachelors";
    EducationLevel["MASTERS"] = "masters";
    EducationLevel["DOCTORATE"] = "doctorate";
})(EducationLevel || (exports.EducationLevel = EducationLevel = {}));
var CommunicationStyle;
(function (CommunicationStyle) {
    CommunicationStyle["ASSERTIVE"] = "assertive";
    CommunicationStyle["PASSIVE"] = "passive";
    CommunicationStyle["AGGRESSIVE"] = "aggressive";
    CommunicationStyle["PASSIVE_AGGRESSIVE"] = "passiveAggressive";
})(CommunicationStyle || (exports.CommunicationStyle = CommunicationStyle = {}));
var Interest;
(function (Interest) {
    Interest["MUSIC"] = "music";
    Interest["TRAVEL"] = "travel";
    Interest["FOOD"] = "food";
    Interest["FITNESS"] = "fitness";
    Interest["READING"] = "reading";
    Interest["MOVIES"] = "movies";
})(Interest || (exports.Interest = Interest = {}));
var SmokingHabit;
(function (SmokingHabit) {
    SmokingHabit["NEVER"] = "never";
    SmokingHabit["SOMETIMES"] = "sometimes";
    SmokingHabit["REGULARLY"] = "regularly";
    SmokingHabit["TRYING_TO_QUIT"] = "tryingToQuit";
})(SmokingHabit || (exports.SmokingHabit = SmokingHabit = {}));
var DrinkingHabit;
(function (DrinkingHabit) {
    DrinkingHabit["NEVER"] = "never";
    DrinkingHabit["SOCIALLY"] = "socially";
    DrinkingHabit["REGULARLY"] = "regularly";
})(DrinkingHabit || (exports.DrinkingHabit = DrinkingHabit = {}));
var WorkoutHabit;
(function (WorkoutHabit) {
    WorkoutHabit["NEVER"] = "never";
    WorkoutHabit["SOMETIMES"] = "sometimes";
    WorkoutHabit["REGULARLY"] = "regularly";
    WorkoutHabit["DAILY"] = "daily";
})(WorkoutHabit || (exports.WorkoutHabit = WorkoutHabit = {}));
var DietaryPreference;
(function (DietaryPreference) {
    DietaryPreference["NONE"] = "none";
    DietaryPreference["VEGETARIAN"] = "vegetarian";
    DietaryPreference["VEGAN"] = "vegan";
    DietaryPreference["PESCATARIAN"] = "pescatarian";
    DietaryPreference["GLUTEN_FREE"] = "glutenFree";
})(DietaryPreference || (exports.DietaryPreference = DietaryPreference = {}));
var SleepingHabit;
(function (SleepingHabit) {
    SleepingHabit["EARLY_BIRD"] = "earlyBird";
    SleepingHabit["NIGHT_OWL"] = "nightOwl";
    SleepingHabit["IRREGULAR"] = "irregular";
})(SleepingHabit || (exports.SleepingHabit = SleepingHabit = {}));
var LoveLanguage;
(function (LoveLanguage) {
    LoveLanguage["WORDS_OF_AFFIRMATION"] = "wordsOfAffirmation";
    LoveLanguage["QUALITY_TIME"] = "qualityTime";
    LoveLanguage["RECEIVING_GIFTS"] = "receivingGifts";
    LoveLanguage["ACTS_OF_SERVICE"] = "actsOfService";
    LoveLanguage["PHYSICAL_TOUCH"] = "physicalTouch";
})(LoveLanguage || (exports.LoveLanguage = LoveLanguage = {}));
let User = class User {
};
exports.User = User;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], User.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], User.prototype, "displayName", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], User.prototype, "username", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], User.prototype, "photoURL", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: GenderOption,
        default: GenderOption.MAN,
    }),
    __metadata("design:type", String)
], User.prototype, "gender", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', nullable: true }),
    __metadata("design:type", Date)
], User.prototype, "dateOfBirth", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], User.prototype, "bio", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], User.prototype, "location", void 0);
__decorate([
    (0, typeorm_1.Column)('float', { nullable: true }),
    __metadata("design:type", Number)
], User.prototype, "latitude", void 0);
__decorate([
    (0, typeorm_1.Column)('float', { nullable: true }),
    __metadata("design:type", Number)
], User.prototype, "longitude", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], User.prototype, "interests", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], User.prototype, "educationLevels", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], User.prototype, "communicationStyles", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: SmokingHabit, nullable: true }),
    __metadata("design:type", String)
], User.prototype, "smokingHabit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: DrinkingHabit, nullable: true }),
    __metadata("design:type", String)
], User.prototype, "drinkingHabit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: WorkoutHabit, nullable: true }),
    __metadata("design:type", String)
], User.prototype, "workoutHabit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: DietaryPreference, nullable: true }),
    __metadata("design:type", String)
], User.prototype, "dietaryPreference", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: SleepingHabit, nullable: true }),
    __metadata("design:type", String)
], User.prototype, "sleepingHabit", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], User.prototype, "loveLanguages", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'json', nullable: true }),
    __metadata("design:type", Array)
], User.prototype, "additionalPhotos", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], User.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], User.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], User.prototype, "lastActive", void 0);
exports.User = User = __decorate([
    (0, typeorm_1.Entity)('users')
], User);
//# sourceMappingURL=user.entity.js.map