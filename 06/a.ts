export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Race = {
  time: number;
  distance: number;
};

const [time, distance] = input.split("\n");
const times = time.split(":")[1].trim().replace(/\s+/g, " ").split(" ").map(
  Number,
);
const dists = distance.split(":")[1].trim().replace(/\s+/g, " ").split(" ")
  .map(Number);

const races: Race[] = [];
for (let i = 0; i < times.length; i++) {
  races.push({ time: times[i], distance: dists[i] });
}

let output = 1;

races.forEach((race) => {
  const distToBeat = race.distance;
  let waysToWin = 0;

  for (let holdTime = 0; holdTime < race.time; holdTime++) {
    const timeLeftToRace = race.time - holdTime;

    if (timeLeftToRace * holdTime> distToBeat) {
      waysToWin++;
    }
  }

  output *= waysToWin;
})

console.log("answer", output);
