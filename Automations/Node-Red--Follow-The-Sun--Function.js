/******************************************************
 EVSE Solar-Aware Amp Control (Bidirectional Grid Sensor)
 - Grid import  (+W): immediate step DOWN
 - Grid export  (-W): debounced step UP
******************************************************/

// --- CONFIG ---
const voltage = 240;
const minAmps = 6;
const maxAmps = 48;
const stepRate = 2;
const stepLimit = 2;

const upMarginWatts = 800;      // safety margin before stepping up
const minHoldTimeMs = 570000;   // debounce for step-UP only (9.5 minutes)

// --- INPUTS ---
let currentAmps = Number(msg.currentAmps) || minAmps;
let gridWatts = Number(msg.payload); // +import / -export

// Normalize export as positive number
let exportWatts = Math.max(0, -gridWatts);

// --- IDEAL AMPS FROM EXPORT ---
let extraAmps = exportWatts / voltage;
let idealAmpsRaw = currentAmps + extraAmps;
idealAmpsRaw = Math.min(maxAmps, Math.max(minAmps, idealAmpsRaw));

// --- DECISION ---
let desiredDirection = "hold";
let proposedTarget = currentAmps;

// ---------- STEP DOWN (IMMEDIATE TO NECESSARY AMPS) ----------
if (gridWatts > 0 && currentAmps > minAmps) {
    desiredDirection = "down";

    // Calculate how many amps we can actually draw without importing
    // i.e., subtract the import watts from current draw
    let possibleAmps = currentAmps - (gridWatts / voltage);

    // Round down to nearest stepRate, and clamp to minAmps
    proposedTarget = Math.max(
        Math.floor(possibleAmps / stepRate) * stepRate,
        minAmps
    );
}

// ---------- STEP UP (DEBOUNCED) ----------
else if (currentAmps < maxAmps) {
    let nextStepAmps = currentAmps + stepRate;
    let wattsNeeded = stepRate * voltage + upMarginWatts;

    if (idealAmpsRaw >= nextStepAmps && exportWatts >= wattsNeeded) {
        desiredDirection = "up";
        // proposedTarget = Math.min(currentAmps + stepLimit, maxAmps);
        let idealTarget = Math.floor(idealAmpsRaw / stepRate) * stepRate;
        proposedTarget = Math.min(idealTarget, maxAmps);
    }
}

// --- STATE / DEBOUNCE ---
let now = Date.now();
let last = flow.get("evseLastDecision") || {
    direction: "hold",
    target: currentAmps,
    timestamp: now
};

let targetAmps = currentAmps;

// DOWN = instant
if (desiredDirection === "down") {
    targetAmps = proposedTarget;
    last = { direction: "hold", target: targetAmps, timestamp: now };
}

// UP = time-smoothed
else if (desiredDirection === "up") {
    // if (last.direction !== "up" || last.target !== proposedTarget) {
    if (last.direction !== "up") {
        last = { direction: "up", target: proposedTarget, timestamp: now };
    } else if (now - last.timestamp >= minHoldTimeMs) {
        targetAmps = proposedTarget;
    }
}

// HOLD
else {
    last = { direction: "hold", target: currentAmps, timestamp: now };
}

flow.set("evseLastDecision", last);

// --- OUTPUT ---
msg.targetAmps = targetAmps;
msg.debug = {
    gridWatts,
    exportWatts,
    currentAmps,
    idealAmpsRaw,
    desiredDirection,
    proposedTarget,
    targetAmps
};

node.status({
    fill: gridWatts > 0 ? "red" : "green",
    shape: "ring",
    text: `Target: ${proposedTarget}A Direction: ${desiredDirection}`
});

return msg;
