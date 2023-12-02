export const x = "";
const input = await Deno.readTextFile("./input.txt");

let output = 0;

type CubeSet = {
  red: number;
  green: number;
  blue: number;
};

type Game = {
  id: number;
  set: CubeSet[];
};

const games: Game[] = input.split("\n").filter((x) => x).map((x) => {
  const [game, sets] = x.split(":");
  const id = parseInt(game.split(" ")[1]);
  const set: CubeSet[] = sets.split(";").map((y) => {
    const attempt = { red: 0, green: 0, blue: 0 };

    y.split(",").forEach((z) => {
      const [value, color] = z.trim().split(" ") as [
        string,
        keyof CubeSet,
      ];
      attempt[color] += parseInt(value);
    });

    return attempt;
  });

  return { id, set };
});

// console.log({ games });

games.forEach((game) => {
  const maxRed = game.set.map((x) => x.red).reduce((a, b) => Math.max(a, b));
  const maxGreen = game.set.map((x) => x.green).reduce((a, b) => Math.max(a, b));
  const maxBlue = game.set.map((x) => x.blue).reduce((a, b) => Math.max(a, b));
  const power = maxRed * maxGreen * maxBlue;
  output += power;
});

console.log("answer", output);
