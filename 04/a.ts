export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Card = {
  winning: number[];
  yours: number[];
};

const cards: Card[] = input.split("\n").map((x) => {
  const [_, nums] = x.split(":");
  if (!nums) return { winning: [], yours: [] };

  const [w, y] = nums.trim().split("|");
  return {
    winning: w.trim().split(" ").map((x) => parseInt(x)).filter((x) =>
      !isNaN(x)
    ),
    yours: y.trim().split(" ").map((x) => parseInt(x)).filter((x) => !isNaN(x)),
  };
});

let output = 0;

cards.forEach((card) => {
  let count = 0;

  card.yours.forEach((y) => {
    if (card.winning.includes(y)) {
      count++;
    }
  });
  if (count > 0) {
    output += 2 ** (count - 1);
  }
});

console.log("answer", output);
