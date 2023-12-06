export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Race = {
  time: number;
  distance: number;
};

const [t, d] = input.split("\n");
const time = parseInt(t.split(":")[1].trim().replace(/\s+/g, ""), 10);
const distance = parseInt(d.split(":")[1].trim().replace(/\s+/g, ""), 10);

const race: Race = { time, distance };

let output = 1;

const distToBeat = race.distance;
let waysToWin = 0;

for (let holdTime = 0; holdTime < race.time; holdTime++) {
  const timeLeftToRace = race.time - holdTime;

  if (timeLeftToRace * holdTime > distToBeat) {
    waysToWin++;
  }
}

output *= waysToWin;

console.log("answer", output);
