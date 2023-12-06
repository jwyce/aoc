const main = async () => {
  const AOC_COOKIE = Deno.env.get("AOC_COOKIE");
  const AOC_REPO = Deno.env.get("AOC_REPO");
  const AOC_CONTACT = Deno.env.get("AOC_COOKIE");
  if (!AOC_COOKIE || !AOC_REPO || !AOC_CONTACT) {
    throw new Error(
      "Must set env variables: AOC_COOKIE, AOC_REPO, AOC_CONTACT",
    );
  }

  const relPath = Deno.args[0] || "wip/input.txt";
  const absPath = await Deno.realPath(relPath);

  const getInputUrl = () => {
    const now = new Date(new Date().toLocaleString("en-US", {
      timeZone: "America/New_York",
    }));
    const isDecember = now.getMonth() === 11;

    const day = isDecember ? Math.min(25, now.getDate()) : 25;
    const year = isDecember ? now.getFullYear() : now.getFullYear() - 1;

    return `https://adventofcode.com/${year}/day/${day}/input`;
  };
  console.log(getInputUrl());

  const response = await fetch(getInputUrl(), {
    method: "GET",
    headers: {
      Cookie: AOC_COOKIE,
      "User-Agent": `${AOC_REPO} by ${AOC_CONTACT}`,
    },
  });

  const input = await response.text();
  const encoder = new TextEncoder();
  await Deno.writeFile(absPath, encoder.encode(input));
};

main().catch((err) => {
  console.error(err);
});

