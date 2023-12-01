export const x = "";
const input = await Deno.readTextFile("./input.txt");

const englishToNumber: Record<string, number> = {
  "one": 1,
  "two": 2,
  "three": 3,
  "four": 4,
  "five": 5,
  "six": 6,
  "seven": 7,
  "eight": 8,
  "nine": 9,
  "ten": 10,
  "eleven": 11,
  "twelve": 12,
  "thirteen": 13,
  "fourteen": 14,
  "fifteen": 15,
  "sixteen": 16,
  "seventeen": 17,
  "eightteen": 18,
  "nineteen": 19,
  "twenty": 20,
  "thirty": 30,
  "forty": 40,
  "fifty": 50,
  "sixty": 60,
  "seventy": 70,
  "eighty": 80,
  "ninety": 90,
  "hundred": 100,
  "thousand": 1_000,
  "million": 1_000_000,
  "billion": 1_000_000_000,
  "trillion": 1_000_000_000_000,
};

let output = 0;

input.split("\n").forEach((line) => {
  // console.log({ line });

  const nums = parseNums(line);
  // console.log({ nums });
  const first = +(nums[0] ?? 0);
  const last = +(nums[nums.length - 1] ?? 0);
  // console.log({ first, last });
  const num = first + "" + last;
  // console.log({ num });
  output += +num;
});

console.log("answer", output);

function parseNums(line: string): string[] {
  let word = "";
  const nums = [];

  for (let i = 0; i < line.length; ++i) {
    if (parseInt(line.charAt(i))) {
      nums.push(line.charAt(i));
      word = "";
    } else {
      word += line.charAt(i);

      // console.log({ word });
      if (englishToNumber[word]) {
        nums.push(englishToNumber[word] + "");
        word = word.charAt(word.length - 1);
      } else if (
        !Object.keys(englishToNumber).some((k) => k.startsWith(word))
      ) {
        word = word.substring(1);
      }
    }
  }

  return nums;
}
