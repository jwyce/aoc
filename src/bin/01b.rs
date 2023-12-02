use anyhow::Result;

fn english_to_digit(eng: &str) -> u32 {
    match eng {
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5,
        "six" => 6,
        "seven" => 7,
        "eight" => 8,
        "nine" => 9,
        _ => 0,
    }
}

fn parse_line_to_digits(line: &str) -> Vec<u32> {
    let english_digits = vec![
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    ];
    let mut digits: Vec<u32> = Vec::new();
    let mut word: String = String::new();

    for c in line.chars() {
        if c.is_digit(10) {
            digits.push(c.to_digit(10).unwrap());
            word.clear()
        } else {
            word.push(c);

            if english_to_digit(word.as_str()) != 0 {
                digits.push(english_to_digit(word.as_str()));
                let last_char = match word.chars().last() {
                    Some(c) => c.to_string(),
                    None => String::new(),
                };
                word = last_char;
            }

            if english_digits
                .iter()
                .filter(|d| d.starts_with(word.as_str()))
                .count()
                == 0
            {
                word = word[1..].to_string();
            }
        }
    }

    return digits;
}

fn main() -> Result<()> {
    let calibration: u32 = include_str!("./01.input")
        .lines()
        .map(|s| parse_line_to_digits(s))
        .map(|v| {
            (v.first().unwrap_or(&0).to_string() + v.last().unwrap_or(&0).to_string().as_str())
                .parse::<u32>()
                .unwrap()
        })
        .sum();

    println!("{calibration}");
    return Ok(());
}
