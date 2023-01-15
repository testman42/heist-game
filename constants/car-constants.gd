class_name CarConstants

# Car and traffic related constants accessible everywhere.

const chanceToChangeLane = .0012
const laneMatchThreshold = .3

const spinningSpeedClamp = 10.0
const spinningRotation = .6
const steeringRotation = 1.0/30.0
const steeringSpeedAdjust = 1.0/20.0

const collisionSpeedMultiplier = .9
const collisionSteeringMultiplier = .9
const collisionHealthSpeedMultipler = .8
const collisionHealthSteeringMultipler = .6
const collisionBreakSpeedMultipler = .8
const collisionBreakSteeringMultipler = .6
const collisionBreakThreshold = 3.0

const collisionSpinningThreshold = 16.0
const healthSpinningThreshold = .2

# Traffic spawning constants.

const carSpawnChance = .01
const carChanceGoingUp = .4
