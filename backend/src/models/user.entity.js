"use strict";
var __esDecorate = (this && this.__esDecorate) || function (ctor, descriptorIn, decorators, contextIn, initializers, extraInitializers) {
    function accept(f) { if (f !== void 0 && typeof f !== "function") throw new TypeError("Function expected"); return f; }
    var kind = contextIn.kind, key = kind === "getter" ? "get" : kind === "setter" ? "set" : "value";
    var target = !descriptorIn && ctor ? contextIn["static"] ? ctor : ctor.prototype : null;
    var descriptor = descriptorIn || (target ? Object.getOwnPropertyDescriptor(target, contextIn.name) : {});
    var _, done = false;
    for (var i = decorators.length - 1; i >= 0; i--) {
        var context = {};
        for (var p in contextIn) context[p] = p === "access" ? {} : contextIn[p];
        for (var p in contextIn.access) context.access[p] = contextIn.access[p];
        context.addInitializer = function (f) { if (done) throw new TypeError("Cannot add initializers after decoration has completed"); extraInitializers.push(accept(f || null)); };
        var result = (0, decorators[i])(kind === "accessor" ? { get: descriptor.get, set: descriptor.set } : descriptor[key], context);
        if (kind === "accessor") {
            if (result === void 0) continue;
            if (result === null || typeof result !== "object") throw new TypeError("Object expected");
            if (_ = accept(result.get)) descriptor.get = _;
            if (_ = accept(result.set)) descriptor.set = _;
            if (_ = accept(result.init)) initializers.unshift(_);
        }
        else if (_ = accept(result)) {
            if (kind === "field") initializers.unshift(_);
            else descriptor[key] = _;
        }
    }
    if (target) Object.defineProperty(target, contextIn.name, descriptor);
    done = true;
};
var __runInitializers = (this && this.__runInitializers) || function (thisArg, initializers, value) {
    var useValue = arguments.length > 2;
    for (var i = 0; i < initializers.length; i++) {
        value = useValue ? initializers[i].call(thisArg, value) : initializers[i].call(thisArg);
    }
    return useValue ? value : void 0;
};
var __setFunctionName = (this && this.__setFunctionName) || function (f, name, prefix) {
    if (typeof name === "symbol") name = name.description ? "[".concat(name.description, "]") : "";
    return Object.defineProperty(f, "name", { configurable: true, value: prefix ? "".concat(prefix, " ", name) : name });
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
let User = (() => {
    let _classDecorators = [(0, typeorm_1.Entity)('users')];
    let _classDescriptor;
    let _classExtraInitializers = [];
    let _classThis;
    let _id_decorators;
    let _id_initializers = [];
    let _id_extraInitializers = [];
    let _displayName_decorators;
    let _displayName_initializers = [];
    let _displayName_extraInitializers = [];
    let _username_decorators;
    let _username_initializers = [];
    let _username_extraInitializers = [];
    let _photoURL_decorators;
    let _photoURL_initializers = [];
    let _photoURL_extraInitializers = [];
    let _gender_decorators;
    let _gender_initializers = [];
    let _gender_extraInitializers = [];
    let _dateOfBirth_decorators;
    let _dateOfBirth_initializers = [];
    let _dateOfBirth_extraInitializers = [];
    let _bio_decorators;
    let _bio_initializers = [];
    let _bio_extraInitializers = [];
    let _location_decorators;
    let _location_initializers = [];
    let _location_extraInitializers = [];
    let _latitude_decorators;
    let _latitude_initializers = [];
    let _latitude_extraInitializers = [];
    let _longitude_decorators;
    let _longitude_initializers = [];
    let _longitude_extraInitializers = [];
    let _interests_decorators;
    let _interests_initializers = [];
    let _interests_extraInitializers = [];
    let _educationLevels_decorators;
    let _educationLevels_initializers = [];
    let _educationLevels_extraInitializers = [];
    let _communicationStyles_decorators;
    let _communicationStyles_initializers = [];
    let _communicationStyles_extraInitializers = [];
    let _smokingHabit_decorators;
    let _smokingHabit_initializers = [];
    let _smokingHabit_extraInitializers = [];
    let _drinkingHabit_decorators;
    let _drinkingHabit_initializers = [];
    let _drinkingHabit_extraInitializers = [];
    let _workoutHabit_decorators;
    let _workoutHabit_initializers = [];
    let _workoutHabit_extraInitializers = [];
    let _dietaryPreference_decorators;
    let _dietaryPreference_initializers = [];
    let _dietaryPreference_extraInitializers = [];
    let _sleepingHabit_decorators;
    let _sleepingHabit_initializers = [];
    let _sleepingHabit_extraInitializers = [];
    let _loveLanguages_decorators;
    let _loveLanguages_initializers = [];
    let _loveLanguages_extraInitializers = [];
    let _additionalPhotos_decorators;
    let _additionalPhotos_initializers = [];
    let _additionalPhotos_extraInitializers = [];
    let _createdAt_decorators;
    let _createdAt_initializers = [];
    let _createdAt_extraInitializers = [];
    let _updatedAt_decorators;
    let _updatedAt_initializers = [];
    let _updatedAt_extraInitializers = [];
    let _lastActive_decorators;
    let _lastActive_initializers = [];
    let _lastActive_extraInitializers = [];
    var User = _classThis = class {
        constructor() {
            this.id = __runInitializers(this, _id_initializers, void 0);
            this.displayName = (__runInitializers(this, _id_extraInitializers), __runInitializers(this, _displayName_initializers, void 0));
            this.username = (__runInitializers(this, _displayName_extraInitializers), __runInitializers(this, _username_initializers, void 0));
            this.photoURL = (__runInitializers(this, _username_extraInitializers), __runInitializers(this, _photoURL_initializers, void 0));
            this.gender = (__runInitializers(this, _photoURL_extraInitializers), __runInitializers(this, _gender_initializers, void 0));
            this.dateOfBirth = (__runInitializers(this, _gender_extraInitializers), __runInitializers(this, _dateOfBirth_initializers, void 0));
            this.bio = (__runInitializers(this, _dateOfBirth_extraInitializers), __runInitializers(this, _bio_initializers, void 0));
            this.location = (__runInitializers(this, _bio_extraInitializers), __runInitializers(this, _location_initializers, void 0));
            this.latitude = (__runInitializers(this, _location_extraInitializers), __runInitializers(this, _latitude_initializers, void 0));
            this.longitude = (__runInitializers(this, _latitude_extraInitializers), __runInitializers(this, _longitude_initializers, void 0));
            this.interests = (__runInitializers(this, _longitude_extraInitializers), __runInitializers(this, _interests_initializers, void 0));
            this.educationLevels = (__runInitializers(this, _interests_extraInitializers), __runInitializers(this, _educationLevels_initializers, void 0));
            this.communicationStyles = (__runInitializers(this, _educationLevels_extraInitializers), __runInitializers(this, _communicationStyles_initializers, void 0));
            this.smokingHabit = (__runInitializers(this, _communicationStyles_extraInitializers), __runInitializers(this, _smokingHabit_initializers, void 0));
            this.drinkingHabit = (__runInitializers(this, _smokingHabit_extraInitializers), __runInitializers(this, _drinkingHabit_initializers, void 0));
            this.workoutHabit = (__runInitializers(this, _drinkingHabit_extraInitializers), __runInitializers(this, _workoutHabit_initializers, void 0));
            this.dietaryPreference = (__runInitializers(this, _workoutHabit_extraInitializers), __runInitializers(this, _dietaryPreference_initializers, void 0));
            this.sleepingHabit = (__runInitializers(this, _dietaryPreference_extraInitializers), __runInitializers(this, _sleepingHabit_initializers, void 0));
            this.loveLanguages = (__runInitializers(this, _sleepingHabit_extraInitializers), __runInitializers(this, _loveLanguages_initializers, void 0));
            this.additionalPhotos = (__runInitializers(this, _loveLanguages_extraInitializers), __runInitializers(this, _additionalPhotos_initializers, void 0));
            this.createdAt = (__runInitializers(this, _additionalPhotos_extraInitializers), __runInitializers(this, _createdAt_initializers, void 0));
            this.updatedAt = (__runInitializers(this, _createdAt_extraInitializers), __runInitializers(this, _updatedAt_initializers, void 0));
            this.lastActive = (__runInitializers(this, _updatedAt_extraInitializers), __runInitializers(this, _lastActive_initializers, void 0));
            __runInitializers(this, _lastActive_extraInitializers);
        }
    };
    __setFunctionName(_classThis, "User");
    (() => {
        const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(null) : void 0;
        _id_decorators = [(0, typeorm_1.PrimaryGeneratedColumn)('uuid')];
        _displayName_decorators = [(0, typeorm_1.Column)()];
        _username_decorators = [(0, typeorm_1.Column)()];
        _photoURL_decorators = [(0, typeorm_1.Column)({ nullable: true })];
        _gender_decorators = [(0, typeorm_1.Column)({
                type: 'enum',
                enum: GenderOption,
                default: GenderOption.MAN,
            })];
        _dateOfBirth_decorators = [(0, typeorm_1.Column)({ type: 'date', nullable: true })];
        _bio_decorators = [(0, typeorm_1.Column)({ nullable: true })];
        _location_decorators = [(0, typeorm_1.Column)({ nullable: true })];
        _latitude_decorators = [(0, typeorm_1.Column)('float', { nullable: true })];
        _longitude_decorators = [(0, typeorm_1.Column)('float', { nullable: true })];
        _interests_decorators = [(0, typeorm_1.Column)({ type: 'json', nullable: true })];
        _educationLevels_decorators = [(0, typeorm_1.Column)({ type: 'json', nullable: true })];
        _communicationStyles_decorators = [(0, typeorm_1.Column)({ type: 'json', nullable: true })];
        _smokingHabit_decorators = [(0, typeorm_1.Column)({ type: 'enum', enum: SmokingHabit, nullable: true })];
        _drinkingHabit_decorators = [(0, typeorm_1.Column)({ type: 'enum', enum: DrinkingHabit, nullable: true })];
        _workoutHabit_decorators = [(0, typeorm_1.Column)({ type: 'enum', enum: WorkoutHabit, nullable: true })];
        _dietaryPreference_decorators = [(0, typeorm_1.Column)({ type: 'enum', enum: DietaryPreference, nullable: true })];
        _sleepingHabit_decorators = [(0, typeorm_1.Column)({ type: 'enum', enum: SleepingHabit, nullable: true })];
        _loveLanguages_decorators = [(0, typeorm_1.Column)({ type: 'json', nullable: true })];
        _additionalPhotos_decorators = [(0, typeorm_1.Column)({ type: 'json', nullable: true })];
        _createdAt_decorators = [(0, typeorm_1.CreateDateColumn)()];
        _updatedAt_decorators = [(0, typeorm_1.UpdateDateColumn)()];
        _lastActive_decorators = [(0, typeorm_1.Column)({ type: 'timestamp', nullable: true })];
        __esDecorate(null, null, _id_decorators, { kind: "field", name: "id", static: false, private: false, access: { has: obj => "id" in obj, get: obj => obj.id, set: (obj, value) => { obj.id = value; } }, metadata: _metadata }, _id_initializers, _id_extraInitializers);
        __esDecorate(null, null, _displayName_decorators, { kind: "field", name: "displayName", static: false, private: false, access: { has: obj => "displayName" in obj, get: obj => obj.displayName, set: (obj, value) => { obj.displayName = value; } }, metadata: _metadata }, _displayName_initializers, _displayName_extraInitializers);
        __esDecorate(null, null, _username_decorators, { kind: "field", name: "username", static: false, private: false, access: { has: obj => "username" in obj, get: obj => obj.username, set: (obj, value) => { obj.username = value; } }, metadata: _metadata }, _username_initializers, _username_extraInitializers);
        __esDecorate(null, null, _photoURL_decorators, { kind: "field", name: "photoURL", static: false, private: false, access: { has: obj => "photoURL" in obj, get: obj => obj.photoURL, set: (obj, value) => { obj.photoURL = value; } }, metadata: _metadata }, _photoURL_initializers, _photoURL_extraInitializers);
        __esDecorate(null, null, _gender_decorators, { kind: "field", name: "gender", static: false, private: false, access: { has: obj => "gender" in obj, get: obj => obj.gender, set: (obj, value) => { obj.gender = value; } }, metadata: _metadata }, _gender_initializers, _gender_extraInitializers);
        __esDecorate(null, null, _dateOfBirth_decorators, { kind: "field", name: "dateOfBirth", static: false, private: false, access: { has: obj => "dateOfBirth" in obj, get: obj => obj.dateOfBirth, set: (obj, value) => { obj.dateOfBirth = value; } }, metadata: _metadata }, _dateOfBirth_initializers, _dateOfBirth_extraInitializers);
        __esDecorate(null, null, _bio_decorators, { kind: "field", name: "bio", static: false, private: false, access: { has: obj => "bio" in obj, get: obj => obj.bio, set: (obj, value) => { obj.bio = value; } }, metadata: _metadata }, _bio_initializers, _bio_extraInitializers);
        __esDecorate(null, null, _location_decorators, { kind: "field", name: "location", static: false, private: false, access: { has: obj => "location" in obj, get: obj => obj.location, set: (obj, value) => { obj.location = value; } }, metadata: _metadata }, _location_initializers, _location_extraInitializers);
        __esDecorate(null, null, _latitude_decorators, { kind: "field", name: "latitude", static: false, private: false, access: { has: obj => "latitude" in obj, get: obj => obj.latitude, set: (obj, value) => { obj.latitude = value; } }, metadata: _metadata }, _latitude_initializers, _latitude_extraInitializers);
        __esDecorate(null, null, _longitude_decorators, { kind: "field", name: "longitude", static: false, private: false, access: { has: obj => "longitude" in obj, get: obj => obj.longitude, set: (obj, value) => { obj.longitude = value; } }, metadata: _metadata }, _longitude_initializers, _longitude_extraInitializers);
        __esDecorate(null, null, _interests_decorators, { kind: "field", name: "interests", static: false, private: false, access: { has: obj => "interests" in obj, get: obj => obj.interests, set: (obj, value) => { obj.interests = value; } }, metadata: _metadata }, _interests_initializers, _interests_extraInitializers);
        __esDecorate(null, null, _educationLevels_decorators, { kind: "field", name: "educationLevels", static: false, private: false, access: { has: obj => "educationLevels" in obj, get: obj => obj.educationLevels, set: (obj, value) => { obj.educationLevels = value; } }, metadata: _metadata }, _educationLevels_initializers, _educationLevels_extraInitializers);
        __esDecorate(null, null, _communicationStyles_decorators, { kind: "field", name: "communicationStyles", static: false, private: false, access: { has: obj => "communicationStyles" in obj, get: obj => obj.communicationStyles, set: (obj, value) => { obj.communicationStyles = value; } }, metadata: _metadata }, _communicationStyles_initializers, _communicationStyles_extraInitializers);
        __esDecorate(null, null, _smokingHabit_decorators, { kind: "field", name: "smokingHabit", static: false, private: false, access: { has: obj => "smokingHabit" in obj, get: obj => obj.smokingHabit, set: (obj, value) => { obj.smokingHabit = value; } }, metadata: _metadata }, _smokingHabit_initializers, _smokingHabit_extraInitializers);
        __esDecorate(null, null, _drinkingHabit_decorators, { kind: "field", name: "drinkingHabit", static: false, private: false, access: { has: obj => "drinkingHabit" in obj, get: obj => obj.drinkingHabit, set: (obj, value) => { obj.drinkingHabit = value; } }, metadata: _metadata }, _drinkingHabit_initializers, _drinkingHabit_extraInitializers);
        __esDecorate(null, null, _workoutHabit_decorators, { kind: "field", name: "workoutHabit", static: false, private: false, access: { has: obj => "workoutHabit" in obj, get: obj => obj.workoutHabit, set: (obj, value) => { obj.workoutHabit = value; } }, metadata: _metadata }, _workoutHabit_initializers, _workoutHabit_extraInitializers);
        __esDecorate(null, null, _dietaryPreference_decorators, { kind: "field", name: "dietaryPreference", static: false, private: false, access: { has: obj => "dietaryPreference" in obj, get: obj => obj.dietaryPreference, set: (obj, value) => { obj.dietaryPreference = value; } }, metadata: _metadata }, _dietaryPreference_initializers, _dietaryPreference_extraInitializers);
        __esDecorate(null, null, _sleepingHabit_decorators, { kind: "field", name: "sleepingHabit", static: false, private: false, access: { has: obj => "sleepingHabit" in obj, get: obj => obj.sleepingHabit, set: (obj, value) => { obj.sleepingHabit = value; } }, metadata: _metadata }, _sleepingHabit_initializers, _sleepingHabit_extraInitializers);
        __esDecorate(null, null, _loveLanguages_decorators, { kind: "field", name: "loveLanguages", static: false, private: false, access: { has: obj => "loveLanguages" in obj, get: obj => obj.loveLanguages, set: (obj, value) => { obj.loveLanguages = value; } }, metadata: _metadata }, _loveLanguages_initializers, _loveLanguages_extraInitializers);
        __esDecorate(null, null, _additionalPhotos_decorators, { kind: "field", name: "additionalPhotos", static: false, private: false, access: { has: obj => "additionalPhotos" in obj, get: obj => obj.additionalPhotos, set: (obj, value) => { obj.additionalPhotos = value; } }, metadata: _metadata }, _additionalPhotos_initializers, _additionalPhotos_extraInitializers);
        __esDecorate(null, null, _createdAt_decorators, { kind: "field", name: "createdAt", static: false, private: false, access: { has: obj => "createdAt" in obj, get: obj => obj.createdAt, set: (obj, value) => { obj.createdAt = value; } }, metadata: _metadata }, _createdAt_initializers, _createdAt_extraInitializers);
        __esDecorate(null, null, _updatedAt_decorators, { kind: "field", name: "updatedAt", static: false, private: false, access: { has: obj => "updatedAt" in obj, get: obj => obj.updatedAt, set: (obj, value) => { obj.updatedAt = value; } }, metadata: _metadata }, _updatedAt_initializers, _updatedAt_extraInitializers);
        __esDecorate(null, null, _lastActive_decorators, { kind: "field", name: "lastActive", static: false, private: false, access: { has: obj => "lastActive" in obj, get: obj => obj.lastActive, set: (obj, value) => { obj.lastActive = value; } }, metadata: _metadata }, _lastActive_initializers, _lastActive_extraInitializers);
        __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
        User = _classThis = _classDescriptor.value;
        if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
        __runInitializers(_classThis, _classExtraInitializers);
    })();
    return User = _classThis;
})();
exports.User = User;
