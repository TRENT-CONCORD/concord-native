"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExploreModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const explore_controller_1 = require("./explore.controller");
const explore_service_1 = require("./explore.service");
const user_entity_1 = require("../models/user.entity");
const explore_gateway_1 = require("./explore.gateway");
const saved_filter_entity_1 = require("./models/saved-filter.entity");
let ExploreModule = class ExploreModule {
};
exports.ExploreModule = ExploreModule;
exports.ExploreModule = ExploreModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([user_entity_1.User, saved_filter_entity_1.SavedFilter])],
        controllers: [explore_controller_1.ExploreController],
        providers: [explore_service_1.ExploreService, explore_gateway_1.ExploreGateway],
        exports: [explore_service_1.ExploreService],
    })
], ExploreModule);
//# sourceMappingURL=explore.module.js.map