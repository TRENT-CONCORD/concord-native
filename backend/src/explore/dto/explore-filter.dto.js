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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExploreFilterDto = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const user_entity_1 = require("../../models/user.entity");
let ExploreFilterDto = (() => {
    var _a;
    let _genders_decorators;
    let _genders_initializers = [];
    let _genders_extraInitializers = [];
    let _minAge_decorators;
    let _minAge_initializers = [];
    let _minAge_extraInitializers = [];
    let _maxAge_decorators;
    let _maxAge_initializers = [];
    let _maxAge_extraInitializers = [];
    let _educationLevels_decorators;
    let _educationLevels_initializers = [];
    let _educationLevels_extraInitializers = [];
    let _communicationStyles_decorators;
    let _communicationStyles_initializers = [];
    let _communicationStyles_extraInitializers = [];
    let _interests_decorators;
    let _interests_initializers = [];
    let _interests_extraInitializers = [];
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
    let _limit_decorators;
    let _limit_initializers = [];
    let _limit_extraInitializers = [];
    let _offset_decorators;
    let _offset_initializers = [];
    let _offset_extraInitializers = [];
    let _latitude_decorators;
    let _latitude_initializers = [];
    let _latitude_extraInitializers = [];
    let _longitude_decorators;
    let _longitude_initializers = [];
    let _longitude_extraInitializers = [];
    let _maxDistance_decorators;
    let _maxDistance_initializers = [];
    let _maxDistance_extraInitializers = [];
    return _a = class ExploreFilterDto {
            constructor() {
                this.genders = __runInitializers(this, _genders_initializers, void 0);
                this.minAge = (__runInitializers(this, _genders_extraInitializers), __runInitializers(this, _minAge_initializers, void 0));
                this.maxAge = (__runInitializers(this, _minAge_extraInitializers), __runInitializers(this, _maxAge_initializers, void 0));
                this.educationLevels = (__runInitializers(this, _maxAge_extraInitializers), __runInitializers(this, _educationLevels_initializers, void 0));
                this.communicationStyles = (__runInitializers(this, _educationLevels_extraInitializers), __runInitializers(this, _communicationStyles_initializers, void 0));
                this.interests = (__runInitializers(this, _communicationStyles_extraInitializers), __runInitializers(this, _interests_initializers, void 0));
                this.smokingHabit = (__runInitializers(this, _interests_extraInitializers), __runInitializers(this, _smokingHabit_initializers, void 0));
                this.drinkingHabit = (__runInitializers(this, _smokingHabit_extraInitializers), __runInitializers(this, _drinkingHabit_initializers, void 0));
                this.workoutHabit = (__runInitializers(this, _drinkingHabit_extraInitializers), __runInitializers(this, _workoutHabit_initializers, void 0));
                this.dietaryPreference = (__runInitializers(this, _workoutHabit_extraInitializers), __runInitializers(this, _dietaryPreference_initializers, void 0));
                this.sleepingHabit = (__runInitializers(this, _dietaryPreference_extraInitializers), __runInitializers(this, _sleepingHabit_initializers, void 0));
                this.loveLanguages = (__runInitializers(this, _sleepingHabit_extraInitializers), __runInitializers(this, _loveLanguages_initializers, void 0));
                this.limit = (__runInitializers(this, _loveLanguages_extraInitializers), __runInitializers(this, _limit_initializers, 20));
                this.offset = (__runInitializers(this, _limit_extraInitializers), __runInitializers(this, _offset_initializers, 0));
                this.latitude = (__runInitializers(this, _offset_extraInitializers), __runInitializers(this, _latitude_initializers, void 0));
                this.longitude = (__runInitializers(this, _latitude_extraInitializers), __runInitializers(this, _longitude_initializers, void 0));
                this.maxDistance = (__runInitializers(this, _longitude_extraInitializers), __runInitializers(this, _maxDistance_initializers, void 0));
                __runInitializers(this, _maxDistance_extraInitializers);
            }
        },
        (() => {
            const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(null) : void 0;
            _genders_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsArray)(), (0, class_validator_1.IsEnum)(user_entity_1.GenderOption, { each: true })];
            _minAge_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsInt)(), (0, class_validator_1.Min)(18), (0, class_validator_1.Max)(100)];
            _maxAge_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsInt)(), (0, class_validator_1.Min)(18), (0, class_validator_1.Max)(100)];
            _educationLevels_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsArray)(), (0, class_validator_1.IsEnum)(user_entity_1.EducationLevel, { each: true }), (0, class_validator_1.ArrayMinSize)(0), (0, class_validator_1.ArrayMaxSize)(5)];
            _communicationStyles_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsArray)(), (0, class_validator_1.IsEnum)(user_entity_1.CommunicationStyle, { each: true }), (0, class_validator_1.ArrayMinSize)(0), (0, class_validator_1.ArrayMaxSize)(4)];
            _interests_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsArray)(), (0, class_validator_1.IsEnum)(user_entity_1.Interest, { each: true }), (0, class_validator_1.ArrayMinSize)(0), (0, class_validator_1.ArrayMaxSize)(10)];
            _smokingHabit_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsEnum)(user_entity_1.SmokingHabit)];
            _drinkingHabit_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsEnum)(user_entity_1.DrinkingHabit)];
            _workoutHabit_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsEnum)(user_entity_1.WorkoutHabit)];
            _dietaryPreference_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsEnum)(user_entity_1.DietaryPreference)];
            _sleepingHabit_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsEnum)(user_entity_1.SleepingHabit)];
            _loveLanguages_decorators = [(0, class_validator_1.IsOptional)(), (0, class_validator_1.IsArray)(), (0, class_validator_1.IsEnum)(user_entity_1.LoveLanguage, { each: true }), (0, class_validator_1.ArrayMinSize)(0), (0, class_validator_1.ArrayMaxSize)(5)];
            _limit_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsInt)(), (0, class_validator_1.Min)(1), (0, class_validator_1.Max)(100)];
            _offset_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsInt)(), (0, class_validator_1.Min)(0)];
            _latitude_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsNumber)()];
            _longitude_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsNumber)()];
            _maxDistance_decorators = [(0, class_validator_1.IsOptional)(), (0, class_transformer_1.Type)(() => Number), (0, class_validator_1.IsInt)(), (0, class_validator_1.Min)(1), (0, class_validator_1.Max)(1000)];
            __esDecorate(null, null, _genders_decorators, { kind: "field", name: "genders", static: false, private: false, access: { has: obj => "genders" in obj, get: obj => obj.genders, set: (obj, value) => { obj.genders = value; } }, metadata: _metadata }, _genders_initializers, _genders_extraInitializers);
            __esDecorate(null, null, _minAge_decorators, { kind: "field", name: "minAge", static: false, private: false, access: { has: obj => "minAge" in obj, get: obj => obj.minAge, set: (obj, value) => { obj.minAge = value; } }, metadata: _metadata }, _minAge_initializers, _minAge_extraInitializers);
            __esDecorate(null, null, _maxAge_decorators, { kind: "field", name: "maxAge", static: false, private: false, access: { has: obj => "maxAge" in obj, get: obj => obj.maxAge, set: (obj, value) => { obj.maxAge = value; } }, metadata: _metadata }, _maxAge_initializers, _maxAge_extraInitializers);
            __esDecorate(null, null, _educationLevels_decorators, { kind: "field", name: "educationLevels", static: false, private: false, access: { has: obj => "educationLevels" in obj, get: obj => obj.educationLevels, set: (obj, value) => { obj.educationLevels = value; } }, metadata: _metadata }, _educationLevels_initializers, _educationLevels_extraInitializers);
            __esDecorate(null, null, _communicationStyles_decorators, { kind: "field", name: "communicationStyles", static: false, private: false, access: { has: obj => "communicationStyles" in obj, get: obj => obj.communicationStyles, set: (obj, value) => { obj.communicationStyles = value; } }, metadata: _metadata }, _communicationStyles_initializers, _communicationStyles_extraInitializers);
            __esDecorate(null, null, _interests_decorators, { kind: "field", name: "interests", static: false, private: false, access: { has: obj => "interests" in obj, get: obj => obj.interests, set: (obj, value) => { obj.interests = value; } }, metadata: _metadata }, _interests_initializers, _interests_extraInitializers);
            __esDecorate(null, null, _smokingHabit_decorators, { kind: "field", name: "smokingHabit", static: false, private: false, access: { has: obj => "smokingHabit" in obj, get: obj => obj.smokingHabit, set: (obj, value) => { obj.smokingHabit = value; } }, metadata: _metadata }, _smokingHabit_initializers, _smokingHabit_extraInitializers);
            __esDecorate(null, null, _drinkingHabit_decorators, { kind: "field", name: "drinkingHabit", static: false, private: false, access: { has: obj => "drinkingHabit" in obj, get: obj => obj.drinkingHabit, set: (obj, value) => { obj.drinkingHabit = value; } }, metadata: _metadata }, _drinkingHabit_initializers, _drinkingHabit_extraInitializers);
            __esDecorate(null, null, _workoutHabit_decorators, { kind: "field", name: "workoutHabit", static: false, private: false, access: { has: obj => "workoutHabit" in obj, get: obj => obj.workoutHabit, set: (obj, value) => { obj.workoutHabit = value; } }, metadata: _metadata }, _workoutHabit_initializers, _workoutHabit_extraInitializers);
            __esDecorate(null, null, _dietaryPreference_decorators, { kind: "field", name: "dietaryPreference", static: false, private: false, access: { has: obj => "dietaryPreference" in obj, get: obj => obj.dietaryPreference, set: (obj, value) => { obj.dietaryPreference = value; } }, metadata: _metadata }, _dietaryPreference_initializers, _dietaryPreference_extraInitializers);
            __esDecorate(null, null, _sleepingHabit_decorators, { kind: "field", name: "sleepingHabit", static: false, private: false, access: { has: obj => "sleepingHabit" in obj, get: obj => obj.sleepingHabit, set: (obj, value) => { obj.sleepingHabit = value; } }, metadata: _metadata }, _sleepingHabit_initializers, _sleepingHabit_extraInitializers);
            __esDecorate(null, null, _loveLanguages_decorators, { kind: "field", name: "loveLanguages", static: false, private: false, access: { has: obj => "loveLanguages" in obj, get: obj => obj.loveLanguages, set: (obj, value) => { obj.loveLanguages = value; } }, metadata: _metadata }, _loveLanguages_initializers, _loveLanguages_extraInitializers);
            __esDecorate(null, null, _limit_decorators, { kind: "field", name: "limit", static: false, private: false, access: { has: obj => "limit" in obj, get: obj => obj.limit, set: (obj, value) => { obj.limit = value; } }, metadata: _metadata }, _limit_initializers, _limit_extraInitializers);
            __esDecorate(null, null, _offset_decorators, { kind: "field", name: "offset", static: false, private: false, access: { has: obj => "offset" in obj, get: obj => obj.offset, set: (obj, value) => { obj.offset = value; } }, metadata: _metadata }, _offset_initializers, _offset_extraInitializers);
            __esDecorate(null, null, _latitude_decorators, { kind: "field", name: "latitude", static: false, private: false, access: { has: obj => "latitude" in obj, get: obj => obj.latitude, set: (obj, value) => { obj.latitude = value; } }, metadata: _metadata }, _latitude_initializers, _latitude_extraInitializers);
            __esDecorate(null, null, _longitude_decorators, { kind: "field", name: "longitude", static: false, private: false, access: { has: obj => "longitude" in obj, get: obj => obj.longitude, set: (obj, value) => { obj.longitude = value; } }, metadata: _metadata }, _longitude_initializers, _longitude_extraInitializers);
            __esDecorate(null, null, _maxDistance_decorators, { kind: "field", name: "maxDistance", static: false, private: false, access: { has: obj => "maxDistance" in obj, get: obj => obj.maxDistance, set: (obj, value) => { obj.maxDistance = value; } }, metadata: _metadata }, _maxDistance_initializers, _maxDistance_extraInitializers);
            if (_metadata) Object.defineProperty(_a, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
        })(),
        _a;
})();
exports.ExploreFilterDto = ExploreFilterDto;
