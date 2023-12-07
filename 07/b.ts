export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Game = {
  hand: string[];
  bid: number;
};

type Outcome =
  | "high card"
  | "one pair"
  | "two pair"
  | "three of a kind"
  | "full house"
  | "four of a kind"
  | "five of a kind";

const games = input.split("\n").filter((x) => x).map((game) => {
  const [hand, bid] = game.split(" ");
  return { hand: hand.split(""), bid: Number(bid) };
});

const strengths = {
  J: 0,
  2: 1,
  3: 2,
  4: 3,
  5: 4,
  6: 5,
  7: 6,
  8: 7,
  9: 8,
  T: 9,
  Q: 11,
  K: 12,
  A: 13,
};

const handValue: Record<Outcome, number> = {
  "high card": 0,
  "one pair": 1,
  "two pair": 2,
  "three of a kind": 3,
  "full house": 4,
  "four of a kind": 5,
  "five of a kind": 6,
};

const output = (games.map((game) => {
  const counts: Record<string, number> = {};
  const out: { outcome: Outcome; game: Game } = { outcome: "high card", game };

  const handSansJokers = game.hand.filter((x) => x !== "J");

  for (let i = 0; i < handSansJokers.length; i++) {
    const card = handSansJokers[i];
    counts[card] = counts[card] || 0;
    counts[card]++;
  }

  if (Object.values(counts).includes(5)) {
    out.outcome = "five of a kind";
  } else if (Object.values(counts).includes(4)) {
    out.outcome = "four of a kind";
  } else if (Object.values(counts).includes(3)) {
    if (Object.values(counts).includes(2)) {
      out.outcome = "full house";
    } else {
      out.outcome = "three of a kind";
    }
  } else if (Object.values(counts).includes(2)) {
    if (Object.values(counts).filter((x) => x === 2).length === 2) {
      out.outcome = "two pair";
    } else {
      out.outcome = "one pair";
    }
  }

  const numToPairs: Record<string, Outcome> = {
    1: "one pair",
    2: "three of a kind",
    3: "four of a kind",
    4: "five of a kind",
    5: "five of a kind",
  };

  const numJokers = game.hand.filter((x) => x === "J").length;
  if (numJokers > 0) {
    if (out.outcome === "high card") {
      out.outcome = numToPairs[numJokers];
    } else if (out.outcome === "one pair") {
      out.outcome = numToPairs[numJokers + 1];
    } else if (out.outcome === "two pair") {
      out.outcome = "full house";
    } else if (out.outcome === "three of a kind") {
      out.outcome = numToPairs[numJokers + 2];
    } else if (out.outcome === "four of a kind") {
      out.outcome = "five of a kind";
    }
  }

  return out;
})).sort((a, b) => {
  if (handValue[a.outcome] > handValue[b.outcome]) {
    return 1;
  } else if (handValue[a.outcome] < handValue[b.outcome]) {
    return -1;
  } else {
    for (let i = 0; i < a.game.hand.length; i++) {
      const aCard = a.game.hand[i] as keyof typeof strengths;
      const bCard = b.game.hand[i] as keyof typeof strengths;
      if (strengths[aCard] > strengths[bCard]) {
        return 1;
      } else if (strengths[aCard] < strengths[bCard]) {
        return -1;
      }
    }
    return 0;
  }
}).map((game, idx) => {
  const rank = idx + 1;
  // console.log({ game, rank });
  return { ...game, winnings: game.game.bid * rank };
}).reduce((acc, game) => {
  return acc + (game.winnings);
}, 0);

console.log("answer", output);
