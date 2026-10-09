-- =====================================================================
-- PrepNest seed data. Run AFTER schema.sql (Supabase -> SQL Editor).
-- Safe to re-run: categories/problems/companies/GD/presentation are updated in place,
-- questions that already exist are skipped. It never touches user data.
-- =====================================================================

-- Categories (module -> category -> topics shown in the UI)
insert into categories (id, module, name, description, topics, kind, sort_order) values
  ('quant', 'aptitude', 'Quantitative Aptitude', 'Numbers, arithmetic and algebraic problem solving', '["Number System", "Percentage", "Profit & Loss", "Simple Interest", "Compound Interest", "Ratio & Proportion", "Average", "Time & Work", "Time, Speed & Distance", "Problems on Ages", "Mixtures & Allegations", "Permutation & Combination", "Probability", "Algebra", "HCF & LCM"]'::jsonb, 'mcq', 1),
  ('di', 'aptitude', 'Data Interpretation', 'Reading and analyzing tables, graphs and charts', '["Tables", "Bar Graphs", "Line Graphs", "Pie Charts", "Caselet DI", "Missing Data", "Comparison DI", "Mixed DI"]'::jsonb, 'mcq', 2),
  ('logical', 'aptitude', 'Logical Reasoning', 'Pattern recognition and structured deduction', '["Number Series", "Letter Series", "Coding & Decoding", "Blood Relations", "Direction Sense", "Seating Arrangement", "Syllogisms", "Statement & Conclusion", "Puzzles", "Data Sufficiency", "Analogy", "Classification", "Logical Sequence"]'::jsonb, 'mcq', 3),
  ('verbal', 'aptitude', 'Verbal Ability', 'Grammar, vocabulary and reading comprehension', '["Reading Comprehension", "Sentence Correction", "Error Spotting", "Synonyms", "Antonyms", "Vocabulary", "Para Jumbles", "Fill in the Blanks", "Sentence Completion"]'::jsonb, 'mcq', 4),
  ('programming', 'technical', 'Programming', 'Programming language fundamentals', '["C", "C++", "Java", "Python"]'::jsonb, 'mcq', 1),
  ('cs-core', 'technical', 'Computer Science Core', 'Core computer science subjects', '["Data Structures", "Algorithms", "DBMS", "Operating Systems", "Computer Networks", "OOP", "Software Engineering"]'::jsonb, 'mcq', 2),
  ('webdev', 'technical', 'Web Development', 'Modern web development', '["HTML", "CSS", "JavaScript", "React", "Node.js", "REST APIs"]'::jsonb, 'mcq', 3),
  ('database', 'technical', 'Database', 'Database fundamentals', '["SQL", "MySQL", "PostgreSQL", "Database Design"]'::jsonb, 'mcq', 4),
  ('other', 'technical', 'Other', 'Additional technical skills', '["Git & GitHub", "Cloud Basics", "AI/ML Basics", "Cyber Security Basics"]'::jsonb, 'mcq', 5),
  ('basics', 'coding', 'Basic Programming', 'Programming basics', '[]'::jsonb, 'mcq', 1),
  ('arrays', 'coding', 'Arrays', 'Array problems', '[]'::jsonb, 'mcq', 2),
  ('strings', 'coding', 'Strings', 'String problems', '[]'::jsonb, 'mcq', 3),
  ('searching', 'coding', 'Searching', 'Searching algorithms', '[]'::jsonb, 'mcq', 4),
  ('sorting', 'coding', 'Sorting', 'Sorting algorithms', '[]'::jsonb, 'mcq', 5),
  ('linkedlist', 'coding', 'Linked Lists', 'Linked list problems', '[]'::jsonb, 'mcq', 6),
  ('stack', 'coding', 'Stack', 'Stack problems', '[]'::jsonb, 'mcq', 7),
  ('queue', 'coding', 'Queue', 'Queue problems', '[]'::jsonb, 'mcq', 8),
  ('trees', 'coding', 'Trees', 'Tree problems', '[]'::jsonb, 'mcq', 9),
  ('graphs', 'coding', 'Graphs', 'Graph problems', '[]'::jsonb, 'mcq', 10),
  ('recursion', 'coding', 'Recursion', 'Recursion problems', '[]'::jsonb, 'mcq', 11),
  ('dp', 'coding', 'Dynamic Programming', 'Dynamic programming problems', '[]'::jsonb, 'mcq', 12),
  ('common', 'hr', 'Common HR', 'Frequently asked HR questions', '["Common HR"]'::jsonb, 'prompt', 1),
  ('behavioral', 'hr', 'Behavioral', 'Past-experience questions', '["Behavioral"]'::jsonb, 'prompt', 2),
  ('situational', 'hr', 'Situational', 'What-would-you-do questions', '["Situational"]'::jsonb, 'prompt', 3),
  ('freshers', 'hr', 'Freshers', 'Questions for fresh graduates', '["Freshers"]'::jsonb, 'prompt', 4),
  ('hr-sjt', 'hr', 'HR Situational Judgement', 'Choose the best response (used in the full mock test)', '["Situational Judgement"]'::jsonb, 'mcq', 5),
  ('int-general', 'interview', 'General Interview', 'Opening questions for general / role-based / resume interviews', '["General Interview"]'::jsonb, 'prompt', 1),
  ('int-technical', 'interview', 'Technical Interview', 'Core technical interview questions', '["Technical Interview"]'::jsonb, 'prompt', 2),
  ('int-hr', 'interview', 'HR Interview', 'HR round interview questions', '["HR Interview"]'::jsonb, 'prompt', 3)
on conflict (id) do update set module = excluded.module, name = excluded.name, description = excluded.description,
  topics = excluded.topics, kind = excluded.kind, sort_order = excluded.sort_order;

-- Questions: 294 rows (aptitude, technical, HR prompts, interview prompts, HR situational MCQs)
insert into questions (module, category_id, topic, question, options, correct_index, explanation, difficulty, sort_order) values
  ('aptitude', 'quant', 'Percentage', 'A price increases by 20% and then decreases by 20%. What is the net change?', '["4% decrease", "2% decrease", "No change", "4% increase"]'::jsonb, 0, '100 -> 120 -> 96, so the price is 4% lower.', 'Easy', 0),
  ('aptitude', 'quant', 'Percentage', 'What is 35% of 240?', '["72", "84", "96", "108"]'::jsonb, 1, '0.35 x 240 = 84.', 'Easy', 1),
  ('aptitude', 'quant', 'Percentage', 'In a two-candidate election the winner gets 62% of the votes and wins by 144 votes. How many votes were cast in total?', '["500", "600", "720", "800"]'::jsonb, 1, 'Winning margin = 62% - 38% = 24% of total = 144, so total = 600.', 'Medium', 2),
  ('aptitude', 'quant', 'Percentage', 'A''s salary is 25% more than B''s. By what percent is B''s salary less than A''s?', '["15%", "16.67%", "20%", "25%"]'::jsonb, 2, 'Let B = 100, A = 125. Difference 25 is 25/125 = 20% of A.', 'Medium', 3),
  ('aptitude', 'quant', 'Percentage', 'A student needs 40% to pass. He scores 180 marks and fails by 20 marks. What are the maximum marks?', '["450", "500", "550", "600"]'::jsonb, 1, 'Passing marks = 180 + 20 = 200 = 40% of max, so max = 500.', 'Medium', 4),
  ('aptitude', 'quant', 'Profit & Loss', 'An article bought for Rs 500 is sold for Rs 600. What is the profit percentage?', '["10%", "15%", "20%", "25%"]'::jsonb, 2, 'Profit = 100 on cost 500 = 20%.', 'Easy', 5),
  ('aptitude', 'quant', 'Profit & Loss', 'An item is marked 40% above cost price and sold at a 10% discount on the marked price. What is the profit percentage?', '["26%", "30%", "36%", "40%"]'::jsonb, 0, 'SP = 1.4 x 0.9 = 1.26 times the cost, i.e. 26% profit.', 'Medium', 6),
  ('aptitude', 'quant', 'Profit & Loss', 'A shirt is sold at a 15% loss for Rs 850. What was its cost price?', '["Rs 900", "Rs 950", "Rs 1000", "Rs 1050"]'::jsonb, 2, 'SP = 0.85 x CP, so CP = 850 / 0.85 = 1000.', 'Easy', 7),
  ('aptitude', 'quant', 'Profit & Loss', 'Two articles are each sold for Rs 600, one at a 20% gain and the other at a 20% loss. What is the overall result?', '["No gain, no loss", "4% gain", "2% loss", "4% loss"]'::jsonb, 3, 'When two items have the same selling price and equal gain/loss x%, the net loss is x^2/100 = 4%.', 'Medium', 8),
  ('aptitude', 'quant', 'Profit & Loss', 'The cost price of 10 articles equals the selling price of 8 articles. What is the profit percentage?', '["12.5%", "20%", "25%", "30%"]'::jsonb, 2, 'Let CP of one = 1. Then 8 x SP = 10, so SP = 1.25, a 25% profit.', 'Medium', 9),
  ('aptitude', 'quant', 'Ratio & Proportion', 'Two numbers are in the ratio 3:5 and their sum is 96. What is the larger number?', '["36", "48", "60", "72"]'::jsonb, 2, '8 parts = 96, one part = 12, larger = 5 x 12 = 60.', 'Easy', 10),
  ('aptitude', 'quant', 'Ratio & Proportion', 'Rs 1200 is divided in the ratio 2:3:5. What is the largest share?', '["Rs 240", "Rs 360", "Rs 500", "Rs 600"]'::jsonb, 3, 'Total parts = 10, one part = 120, largest = 5 x 120 = 600.', 'Easy', 11),
  ('aptitude', 'quant', 'Ratio & Proportion', 'If a:b = 2:3 and b:c = 4:5, what is a:b:c?', '["4:6:5", "2:3:5", "6:9:10", "8:12:15"]'::jsonb, 3, 'Make b equal: a:b = 8:12 and b:c = 12:15, so a:b:c = 8:12:15.', 'Medium', 12),
  ('aptitude', 'quant', 'Ratio & Proportion', 'What is the fourth proportional to 4, 9 and 12?', '["24", "27", "30", "36"]'::jsonb, 1, '4:9 = 12:x gives x = 9 x 12 / 4 = 27.', 'Easy', 13),
  ('aptitude', 'quant', 'Ratio & Proportion', 'The ratio of boys to girls in a class is 3:2. If there are 12 girls, how many students are there in total?', '["24", "30", "36", "40"]'::jsonb, 1, '2 parts = 12, so 1 part = 6 and total = 5 x 6 = 30.', 'Easy', 14),
  ('aptitude', 'quant', 'Number System', 'Which of the following is a prime number?', '["51", "57", "61", "91"]'::jsonb, 2, '51 = 3x17, 57 = 3x19, 91 = 7x13; 61 has no divisors other than 1 and itself.', 'Easy', 15),
  ('aptitude', 'quant', 'Number System', 'What is the sum of the first 10 natural numbers?', '["45", "50", "55", "60"]'::jsonb, 2, 'n(n+1)/2 = 10 x 11 / 2 = 55.', 'Easy', 16),
  ('aptitude', 'quant', 'Number System', 'What is the unit digit of 7^4?', '["1", "3", "7", "9"]'::jsonb, 0, '7^4 = 2401, so the unit digit is 1.', 'Medium', 17),
  ('aptitude', 'quant', 'Simple Interest', 'What is the simple interest on Rs 2000 for 3 years at 5% per annum?', '["Rs 250", "Rs 300", "Rs 350", "Rs 400"]'::jsonb, 1, 'SI = P x R x T / 100 = 2000 x 5 x 3 / 100 = 300.', 'Easy', 18),
  ('aptitude', 'quant', 'Simple Interest', 'A sum of money doubles itself in 10 years at simple interest. What is the rate of interest per annum?', '["5%", "8%", "10%", "12%"]'::jsonb, 2, 'Interest = principal in 10 years, so R = 100 / 10 = 10%.', 'Medium', 19),
  ('aptitude', 'quant', 'Simple Interest', 'What principal earns Rs 120 simple interest in 2 years at 6% per annum?', '["Rs 800", "Rs 1000", "Rs 1200", "Rs 1500"]'::jsonb, 1, 'P = 120 x 100 / (6 x 2) = 1000.', 'Medium', 20),
  ('aptitude', 'quant', 'Compound Interest', 'What is the compound interest on Rs 1000 for 2 years at 10% per annum (compounded yearly)?', '["Rs 200", "Rs 210", "Rs 220", "Rs 231"]'::jsonb, 1, 'Amount = 1000 x 1.1 x 1.1 = 1210, so CI = 210.', 'Easy', 21),
  ('aptitude', 'quant', 'Compound Interest', 'What is the amount on Rs 5000 for 1 year at 20% per annum compounded half-yearly?', '["Rs 6000", "Rs 6050", "Rs 6100", "Rs 6200"]'::jsonb, 1, 'Rate is 10% per half-year for 2 periods: 5000 x 1.1 x 1.1 = 6050.', 'Medium', 22),
  ('aptitude', 'quant', 'Compound Interest', 'What is the difference between compound interest and simple interest on Rs 1000 for 2 years at 10% per annum?', '["Rs 5", "Rs 10", "Rs 15", "Rs 20"]'::jsonb, 1, 'CI = 210, SI = 200, so the difference is 10.', 'Medium', 23),
  ('aptitude', 'quant', 'Average', 'What is the average of 10, 20, 30, 40 and 50?', '["25", "30", "35", "150"]'::jsonb, 1, 'Sum = 150, divided by 5 = 30.', 'Easy', 24),
  ('aptitude', 'quant', 'Average', 'The average of 5 numbers is 20. If one number, 30, is removed, what is the average of the remaining four?', '["15", "17.5", "18", "20"]'::jsonb, 1, 'Total = 100; remaining sum = 70; 70 / 4 = 17.5.', 'Medium', 25),
  ('aptitude', 'quant', 'Average', 'The average of 7 consecutive integers is 24. What is the largest of them?', '["26", "27", "28", "30"]'::jsonb, 1, 'The middle (4th) number is 24, so the numbers run from 21 to 27.', 'Medium', 26),
  ('aptitude', 'quant', 'Time & Work', 'A can finish a job in 12 days and B in 18 days. Working together, how many days will they take?', '["6 days", "7.2 days", "8 days", "15 days"]'::jsonb, 1, 'Combined rate = 1/12 + 1/18 = 5/36 per day, so 36/5 = 7.2 days.', 'Easy', 27),
  ('aptitude', 'quant', 'Time & Work', '10 men can finish a job in 15 days. How many days will 25 men take?', '["5 days", "6 days", "8 days", "10 days"]'::jsonb, 1, 'Man-days = 150; 150 / 25 = 6 days.', 'Easy', 28),
  ('aptitude', 'quant', 'Time & Work', 'A can do a job in 10 days. He works for 4 days and B finishes the rest in 9 days. In how many days can B alone do the whole job?', '["12 days", "15 days", "18 days", "20 days"]'::jsonb, 1, 'A did 4/10 = 2/5; the remaining 3/5 took B 9 days, so the full job takes 15 days.', 'Medium', 29),
  ('aptitude', 'quant', 'Time, Speed & Distance', 'Convert 72 km/h into m/s.', '["18 m/s", "20 m/s", "15 m/s", "25 m/s"]'::jsonb, 1, 'Multiply by 5/18: 72 x 5/18 = 20.', 'Easy', 30),
  ('aptitude', 'quant', 'Time, Speed & Distance', 'How long does a car travelling at 50 km/h take to cover 150 km?', '["2 hours", "3 hours", "4 hours", "5 hours"]'::jsonb, 1, 'Time = distance / speed = 150 / 50 = 3.', 'Easy', 31),
  ('aptitude', 'quant', 'Time, Speed & Distance', 'A car goes from A to B at 60 km/h and returns at 40 km/h. What is its average speed for the whole trip?', '["52 km/h", "50 km/h", "48 km/h", "45 km/h"]'::jsonb, 2, 'Average speed = 2xy/(x+y) = 2 x 60 x 40 / 100 = 48.', 'Medium', 32),
  ('aptitude', 'quant', 'Problems on Ages', 'A father is three times as old as his son. The sum of their ages is 48. How old is the son?', '["10", "12", "14", "16"]'::jsonb, 1, 'Son = x, father = 3x, 4x = 48, so x = 12.', 'Easy', 33),
  ('aptitude', 'quant', 'Problems on Ages', 'The ages of two people are in the ratio 4:5. After 6 years the ratio becomes 5:6. What is the present age of the elder?', '["24", "30", "36", "40"]'::jsonb, 1, '(4x+6)/(5x+6) = 5/6 gives x = 6; elder = 5 x 6 = 30.', 'Medium', 34),
  ('aptitude', 'quant', 'Problems on Ages', 'A is 5 years older than B and the sum of their ages is 35. How old is B?', '["10", "15", "20", "25"]'::jsonb, 1, 'B + (B+5) = 35, so B = 15.', 'Easy', 35),
  ('aptitude', 'quant', 'Mixtures & Allegations', '2 litres of milk are mixed with 3 litres of water. What percentage of the mixture is milk?', '["30%", "40%", "50%", "60%"]'::jsonb, 1, '2 / 5 = 40%.', 'Easy', 36),
  ('aptitude', 'quant', 'Mixtures & Allegations', 'In what ratio must rice at Rs 20/kg be mixed with rice at Rs 30/kg to get a mixture worth Rs 24/kg?', '["4:3", "2:3", "1:1", "3:2"]'::jsonb, 3, 'Allegation: cheaper : dearer = (30-24) : (24-20) = 6:4 = 3:2.', 'Medium', 37),
  ('aptitude', 'quant', 'Mixtures & Allegations', '20 litres of a solution contain 30% alcohol. 10 litres of water are added. What is the new alcohol percentage?', '["10%", "15%", "20%", "25%"]'::jsonb, 2, 'Alcohol = 6 litres; total = 30 litres; 6/30 = 20%.', 'Medium', 38),
  ('aptitude', 'quant', 'Permutation & Combination', 'In how many ways can 5 different books be arranged on a shelf?', '["24", "60", "120", "720"]'::jsonb, 2, '5! = 120.', 'Easy', 39),
  ('aptitude', 'quant', 'Permutation & Combination', 'In how many ways can 2 students be chosen from a group of 5?', '["5", "10", "20", "25"]'::jsonb, 1, '5C2 = 5 x 4 / 2 = 10.', 'Easy', 40),
  ('aptitude', 'quant', 'Permutation & Combination', 'How many different arrangements can be made from the letters of the word MAT?', '["3", "6", "9", "12"]'::jsonb, 1, '3 distinct letters give 3! = 6.', 'Easy', 41),
  ('aptitude', 'quant', 'Probability', 'What is the probability of getting heads when a fair coin is tossed once?', '["1/3", "1/4", "1", "1/2"]'::jsonb, 3, 'Two equally likely outcomes, one favourable.', 'Easy', 42),
  ('aptitude', 'quant', 'Probability', 'A fair die is rolled once. What is the probability of getting an even number?', '["1/2", "2/3", "1/3", "1/6"]'::jsonb, 0, 'Even numbers 2, 4, 6 are 3 of 6 outcomes.', 'Easy', 43),
  ('aptitude', 'quant', 'Probability', 'One card is drawn from a standard pack of 52. What is the probability that it is an ace?', '["4/13", "1/4", "1/13", "1/26"]'::jsonb, 2, '4 aces in 52 cards = 4/52 = 1/13.', 'Medium', 44),
  ('aptitude', 'quant', 'Algebra', 'If x + 5 = 12, what is the value of x?', '["5", "6", "7", "17"]'::jsonb, 2, 'Subtract 5 from both sides.', 'Easy', 45),
  ('aptitude', 'quant', 'Algebra', 'What are the roots of x^2 - 5x + 6 = 0?', '["2 and -3", "-2 and -3", "2 and 3", "1 and 6"]'::jsonb, 2, 'x^2 - 5x + 6 = (x-2)(x-3).', 'Medium', 46),
  ('aptitude', 'quant', 'Algebra', 'If a + b = 10 and ab = 21, what is a^2 + b^2?', '["58", "61", "79", "121"]'::jsonb, 0, 'a^2 + b^2 = (a+b)^2 - 2ab = 100 - 42 = 58.', 'Medium', 47),
  ('aptitude', 'quant', 'HCF & LCM', 'What is the HCF of 12 and 18?', '["2", "3", "6", "36"]'::jsonb, 2, 'Common factors of 12 and 18: 1, 2, 3, 6.', 'Easy', 48),
  ('aptitude', 'quant', 'HCF & LCM', 'What is the LCM of 4, 6 and 8?', '["12", "24", "32", "48"]'::jsonb, 1, 'LCM = 2^3 x 3 = 24.', 'Easy', 49),
  ('aptitude', 'quant', 'HCF & LCM', 'The product of two numbers is 180 and their HCF is 3. What is their LCM?', '["30", "45", "60", "90"]'::jsonb, 2, 'HCF x LCM = product, so LCM = 180 / 3 = 60.', 'Medium', 50),
  ('aptitude', 'di', 'Tables', 'A table shows monthly sales (units): Jan 120, Feb 150, Mar 180. What are the total sales for the quarter?', '["430", "450", "470", "500"]'::jsonb, 1, '120 + 150 + 180 = 450.', 'Easy', 51),
  ('aptitude', 'di', 'Tables', 'Using the same table (Jan 120, Feb 150, Mar 180), what is the percentage increase in sales from January to March?', '["30%", "40%", "50%", "60%"]'::jsonb, 2, '(180 - 120) / 120 = 50%.', 'Medium', 52),
  ('aptitude', 'di', 'Tables', 'A table lists students per class: Class A 40, Class B 35, Class C 25. What percentage of all students are in Class A?', '["25%", "35%", "40%", "45%"]'::jsonb, 2, '40 / 100 = 40%.', 'Easy', 53),
  ('aptitude', 'di', 'Bar Graphs', 'A bar graph shows production (tonnes): 2019 - 40, 2020 - 50, 2021 - 45, 2022 - 60. Which year had the highest production?', '["2019", "2020", "2021", "2022"]'::jsonb, 3, '60 is the tallest bar.', 'Easy', 54),
  ('aptitude', 'di', 'Bar Graphs', 'For the same bar graph (40, 50, 45, 60 tonnes), what is the average yearly production?', '["45 tonnes", "47.5 tonnes", "48.75 tonnes", "50 tonnes"]'::jsonb, 2, '(40 + 50 + 45 + 60) / 4 = 195 / 4 = 48.75.', 'Medium', 55),
  ('aptitude', 'di', 'Bar Graphs', 'In the same bar graph, by what percentage did production rise from 2021 to 2022?', '["25%", "30%", "33.33%", "40%"]'::jsonb, 2, '(60 - 45) / 45 = 33.33%.', 'Medium', 56),
  ('aptitude', 'di', 'Line Graphs', 'A line graph shows monthly temperature (deg C): Jan 10, Feb 14, Mar 18, Apr 24. Between which consecutive months was the rise largest?', '["February to March", "January to February", "March to April", "All rises are equal"]'::jsonb, 2, 'Rises are 4, 4 and 6; the largest is Mar to Apr.', 'Easy', 57),
  ('aptitude', 'di', 'Line Graphs', 'For the same data (10, 14, 18, 24 deg C), what is the average temperature?', '["15 deg C", "16 deg C", "16.5 deg C", "17 deg C"]'::jsonb, 2, '(10 + 14 + 18 + 24) / 4 = 66 / 4 = 16.5.', 'Easy', 58),
  ('aptitude', 'di', 'Line Graphs', 'For the same data, by what percentage is April''s temperature higher than January''s?', '["100%", "120%", "140%", "160%"]'::jsonb, 2, '(24 - 10) / 10 = 140%.', 'Medium', 59),
  ('aptitude', 'di', 'Pie Charts', 'A pie chart of a family''s monthly expenses of Rs 40,000 shows Rent 30%, Food 25%, Education 20%, Savings 15%, Others 10%. How much is spent on Food?', '["Rs 8,000", "Rs 10,000", "Rs 12,000", "Rs 15,000"]'::jsonb, 1, '25% of 40,000 = 10,000.', 'Easy', 60),
  ('aptitude', 'di', 'Pie Charts', 'In the same pie chart, what is the central angle of the Education sector?', '["54 degrees", "60 degrees", "72 degrees", "90 degrees"]'::jsonb, 2, '20% of 360 = 72.', 'Easy', 61),
  ('aptitude', 'di', 'Pie Charts', 'In the same pie chart, by how much does the Rent expense exceed the Savings?', '["Rs 4,000", "Rs 5,000", "Rs 6,000", "Rs 8,000"]'::jsonb, 2, '(30% - 15%) of 40,000 = 6,000.', 'Medium', 62),
  ('aptitude', 'di', 'Caselet DI', 'A school has 500 students, 60% of them boys. 40% of the boys play cricket. How many boys play cricket?', '["100", "120", "150", "200"]'::jsonb, 1, 'Boys = 300; 40% of 300 = 120.', 'Easy', 63),
  ('aptitude', 'di', 'Caselet DI', 'A company has 200 employees, 45% of them women. 20% of the women are managers. How many women are managers?', '["16", "18", "20", "25"]'::jsonb, 1, 'Women = 90; 20% of 90 = 18.', 'Medium', 64),
  ('aptitude', 'di', 'Caselet DI', 'In a survey of 800 people, 35% like only tea and 25% like only coffee; the rest like both. How many like both?', '["240", "280", "320", "360"]'::jsonb, 2, 'Both = 100 - 35 - 25 = 40% of 800 = 320.', 'Medium', 65),
  ('aptitude', 'di', 'Missing Data', 'A student''s total marks in 4 subjects is 320. Marks in three subjects are 80, 85 and 75. What are the marks in the fourth subject?', '["70", "75", "80", "85"]'::jsonb, 2, '320 - (80 + 85 + 75) = 80.', 'Easy', 66),
  ('aptitude', 'di', 'Missing Data', 'A table shows quarterly revenue: Q1 50, Q2 60, Q3 missing, Q4 80. The annual total is 270. What is Q3?', '["70", "75", "80", "85"]'::jsonb, 2, '270 - (50 + 60 + 80) = 80.', 'Medium', 67),
  ('aptitude', 'di', 'Missing Data', 'The average of 5 values is 12. Four of them are 10, 11, 13 and 14. What is the fifth?', '["10", "11", "12", "13"]'::jsonb, 2, 'Total = 60; 60 - 48 = 12.', 'Medium', 68),
  ('aptitude', 'di', 'Comparison DI', 'Company X sold 400 units at Rs 50 each and company Y sold 300 units at Rs 70 each. Which has the higher revenue?', '["Company X", "Cannot be determined", "Company Y", "Both are equal"]'::jsonb, 2, 'X = 20,000 and Y = 21,000.', 'Easy', 69),
  ('aptitude', 'di', 'Comparison DI', 'In the same case (X: 400 units at Rs 50, Y: 300 units at Rs 70), what is the difference in revenue?', '["Rs 500", "Rs 1,000", "Rs 1,500", "Rs 2,000"]'::jsonb, 1, '21,000 - 20,000 = 1,000.', 'Easy', 70),
  ('aptitude', 'di', 'Comparison DI', 'In the same case, Y''s revenue is what percentage of X''s revenue?', '["95%", "100%", "105%", "110%"]'::jsonb, 2, '21,000 / 20,000 = 105%.', 'Medium', 71),
  ('aptitude', 'di', 'Mixed DI', 'Product P has cost Rs 40 and selling price Rs 50; Product Q has cost Rs 60 and selling price Rs 72. Which product has the higher profit percentage?', '["Product P", "Cannot be said", "Both are equal", "Product Q"]'::jsonb, 0, 'P = 10/40 = 25%; Q = 12/60 = 20%.', 'Medium', 72),
  ('aptitude', 'di', 'Mixed DI', 'Using the same data (P: cost 40, SP 50; Q: cost 60, SP 72), what is the total profit if 10 units of each are sold?', '["Rs 200", "Rs 220", "Rs 240", "Rs 260"]'::jsonb, 1, '10 x (10 + 12) = 220.', 'Medium', 73),
  ('aptitude', 'di', 'Mixed DI', 'Of 500 students, 40% prefer Maths, 30% prefer Science and the rest prefer Arts. How many prefer Arts?', '["100", "125", "150", "175"]'::jsonb, 2, 'Arts = 30% of 500 = 150.', 'Easy', 74),
  ('aptitude', 'logical', 'Number Series', 'Find the next number: 2, 6, 12, 20, 30, ?', '["36", "40", "42", "44"]'::jsonb, 2, 'Differences are 4, 6, 8, 10, so the next difference is 12.', 'Easy', 75),
  ('aptitude', 'logical', 'Number Series', 'Find the next number: 3, 6, 12, 24, 48, ?', '["72", "84", "96", "108"]'::jsonb, 2, 'Each term is double the previous one.', 'Easy', 76),
  ('aptitude', 'logical', 'Number Series', 'Find the next number: 1, 4, 9, 16, 25, ?', '["30", "35", "36", "49"]'::jsonb, 2, 'These are perfect squares: 1^2, 2^2, ... so the next is 6^2.', 'Easy', 77),
  ('aptitude', 'logical', 'Number Series', 'Find the next number: 2, 3, 5, 7, 11, 13, ?', '["15", "16", "17", "19"]'::jsonb, 2, 'The series lists prime numbers in order.', 'Medium', 78),
  ('aptitude', 'logical', 'Number Series', 'Find the next number: 100, 91, 82, 73, ?', '["63", "64", "65", "66"]'::jsonb, 1, 'Each term decreases by 9.', 'Easy', 79),
  ('aptitude', 'logical', 'Coding & Decoding', 'If CAT is coded as DBU, how is DOG coded?', '["ENH", "EPH", "FPH", "EPG"]'::jsonb, 1, 'Each letter is shifted forward by 1: D->E, O->P, G->H.', 'Easy', 80),
  ('aptitude', 'logical', 'Coding & Decoding', 'If A=1, B=2, C=3 and so on, what is the sum of the letter values in the word BAD?', '["6", "7", "8", "9"]'::jsonb, 1, '2 + 1 + 4 = 7.', 'Easy', 81),
  ('aptitude', 'logical', 'Coding & Decoding', 'If MANGO is written as NBOHP, how is APPLE written?', '["BQQMF", "BQQLF", "BPQMF", "CQQMF"]'::jsonb, 0, 'Each letter moves forward by 1: A->B, P->Q, P->Q, L->M, E->F.', 'Easy', 82),
  ('aptitude', 'logical', 'Coding & Decoding', 'If TABLE is coded as 20-1-2-12-5, how is CHAIR coded?', '["3-8-1-9-18", "3-8-1-9-17", "4-8-1-9-18", "3-7-1-9-18"]'::jsonb, 0, 'Each letter is replaced by its alphabet position: C=3, H=8, A=1, I=9, R=18.', 'Medium', 83),
  ('aptitude', 'logical', 'Coding & Decoding', 'If PEN is written as RGP (each letter shifted by 2), how is BOX written?', '["DPZ", "EQA", "CPY", "DQZ"]'::jsonb, 3, 'B->D, O->Q, X->Z.', 'Medium', 84),
  ('aptitude', 'logical', 'Letter Series', 'Find the next letter: A, C, E, G, ?', '["K", "J", "H", "I"]'::jsonb, 3, 'The letters skip one each time: A, C, E, G, I.', 'Easy', 85),
  ('aptitude', 'logical', 'Letter Series', 'Find the next letter: B, D, G, K, ?', '["O", "P", "Q", "R"]'::jsonb, 1, 'Position jumps are +2, +3, +4, +5: K (11) + 5 = P (16).', 'Medium', 86),
  ('aptitude', 'logical', 'Letter Series', 'Find the next letter: Z, X, V, T, ?', '["S", "Q", "P", "R"]'::jsonb, 3, 'Letters move backwards by 2 each time.', 'Easy', 87),
  ('aptitude', 'logical', 'Blood Relations', 'Pointing to a man, a woman says, ''He is the son of my mother''s only son.'' How is the man related to the woman?', '["Uncle", "Son", "Brother", "Nephew"]'::jsonb, 3, 'Her mother''s only son is her brother; his son is her nephew.', 'Medium', 88),
  ('aptitude', 'logical', 'Blood Relations', 'A is the brother of B, B is the sister of C, and C is the father of D. How is A related to D?', '["Father", "Brother", "Uncle", "Cousin"]'::jsonb, 2, 'A and C are siblings, so A is D''s paternal uncle.', 'Medium', 89),
  ('aptitude', 'logical', 'Blood Relations', 'What is your father''s only brother''s daughter to you?', '["Cousin", "Sister", "Niece", "Aunt"]'::jsonb, 0, 'She is the child of your father''s sibling.', 'Easy', 90),
  ('aptitude', 'logical', 'Direction Sense', 'You walk 5 m north, turn right and walk 3 m, then turn right again and walk 5 m. Where are you relative to the starting point?', '["3 m east", "3 m west", "5 m north", "5 m south"]'::jsonb, 0, 'North 5, east 3, south 5 brings you 3 m east of the start.', 'Easy', 91),
  ('aptitude', 'logical', 'Direction Sense', 'A person facing north turns 90 degrees clockwise and then 180 degrees. Which direction is he facing now?', '["West", "South", "East", "North"]'::jsonb, 0, 'Clockwise 90 from north is east; turning 180 more gives west.', 'Easy', 92),
  ('aptitude', 'logical', 'Direction Sense', 'A man walks 4 km west and then 3 km north. How far is he from the starting point in a straight line?', '["1 km", "5 km", "6 km", "7 km"]'::jsonb, 1, 'By Pythagoras, sqrt(4^2 + 3^2) = 5.', 'Easy', 93),
  ('aptitude', 'logical', 'Seating Arrangement', 'Five people A, B, C, D and E sit in a row. A is at the left end, E is at the right end and C is in the middle. B sits immediately to the left of C. Who sits next to E?', '["D", "B", "A", "C"]'::jsonb, 0, 'Order left to right: A, B, C, D, E.', 'Medium', 94),
  ('aptitude', 'logical', 'Seating Arrangement', 'Six people sit around a circular table. A sits opposite D and B sits opposite E. Who sits opposite C?', '["B", "F", "A", "E"]'::jsonb, 1, 'The remaining pair of opposite seats must be C and F.', 'Medium', 95),
  ('aptitude', 'logical', 'Seating Arrangement', 'In a row of 20 students, Ravi is 8th from the left. What is his position from the right?', '["11th", "12th", "13th", "14th"]'::jsonb, 2, 'Position from right = 20 - 8 + 1 = 13.', 'Easy', 96),
  ('aptitude', 'logical', 'Syllogisms', 'Statements: All dogs are mammals. All mammals are animals. Conclusions: I. All dogs are animals. II. All animals are dogs.', '["Only I follows", "Only II follows", "Both I and II follow", "Neither I nor II follows"]'::jsonb, 0, 'By transitivity all dogs are animals; the reverse does not follow.', 'Medium', 97),
  ('aptitude', 'logical', 'Syllogisms', 'Statements: Some pens are books. All books are tables. Conclusions: I. Some pens are tables. II. All pens are tables.', '["Only I follows", "Only II follows", "Both I and II follow", "Neither I nor II follows"]'::jsonb, 0, 'The pens that are books are tables, so I follows; not every pen is a book, so II does not.', 'Medium', 98),
  ('aptitude', 'logical', 'Syllogisms', 'Statements: Some birds are fish. Some fish are cars. Conclusions: I. Some birds are cars. II. Some cars are birds.', '["Only I follows", "Only II follows", "Both I and II follow", "Neither I nor II follows"]'::jsonb, 3, 'Two ''some'' statements never give a definite link between the outer terms.', 'Medium', 99),
  ('aptitude', 'logical', 'Statement & Conclusion', 'Statement: Only students who score above 60% are eligible for the scholarship. Ravi scored 55%. Conclusion: Ravi is not eligible.', '["Definitely follows", "Definitely does not follow", "Data inadequate", "Probably follows"]'::jsonb, 0, '55% is not above 60%, so Ravi fails the stated condition.', 'Medium', 100),
  ('aptitude', 'logical', 'Statement & Conclusion', 'Statement: All metals expand on heating. Copper is a metal. Conclusion: Copper expands on heating.', '["Definitely does not follow", "Definitely follows", "Data inadequate", "Probably follows"]'::jsonb, 1, 'Copper belongs to the group ''metals'', so the general rule applies.', 'Easy', 101),
  ('aptitude', 'logical', 'Statement & Conclusion', 'Statement: Some doctors are teachers. Conclusion: All teachers are doctors.', '["Definitely follows", "Data inadequate", "Definitely does not follow", "Probably follows"]'::jsonb, 2, '''Some'' does not cover every teacher, so the conclusion is not supported.', 'Easy', 102),
  ('aptitude', 'logical', 'Puzzles', 'A two-digit number has digits that add up to 9. When the digits are reversed the number increases by 27. What is the number?', '["18", "27", "36", "45"]'::jsonb, 2, 'Digits a, b with a + b = 9 and 9(b - a) = 27 give b - a = 3, so a = 3, b = 6.', 'Medium', 103),
  ('aptitude', 'logical', 'Puzzles', 'A farmyard has chickens and cows with 20 heads and 56 legs in total. How many cows are there?', '["6", "8", "10", "12"]'::jsonb, 1, '4c + 2(20 - c) = 56 gives c = 8.', 'Medium', 104),
  ('aptitude', 'logical', 'Puzzles', 'What is the angle between the hour and minute hands of a clock at 3:15?', '["0 degrees", "7.5 degrees", "15 degrees", "30 degrees"]'::jsonb, 1, 'Hour hand = 3 x 30 + 15 x 0.5 = 97.5; minute hand = 90; difference = 7.5.', 'Hard', 105),
  ('aptitude', 'logical', 'Data Sufficiency', 'What is the value of x? I. x + y = 10. II. x - y = 2.', '["Statement I alone is sufficient", "Statement II alone is sufficient", "Both statements together are needed", "Neither statement is sufficient"]'::jsonb, 2, 'Either statement alone leaves two unknowns; together they give x = 6.', 'Easy', 106),
  ('aptitude', 'logical', 'Data Sufficiency', 'Is n even? I. n is divisible by 4. II. n is prime.', '["Statement I alone is sufficient", "Statement II alone is sufficient", "Both statements together are needed", "Neither statement is sufficient"]'::jsonb, 0, 'Anything divisible by 4 is even. A prime can be 2 (even) or odd, so II alone cannot decide.', 'Medium', 107),
  ('aptitude', 'logical', 'Data Sufficiency', 'What is the area of a rectangle? I. The length is 8 m. II. The perimeter is 28 m.', '["Statement I alone is sufficient", "Statement II alone is sufficient", "Both statements together are needed", "Neither statement is sufficient"]'::jsonb, 2, 'The perimeter gives the width only once the length is known (8 + W = 14, W = 6).', 'Medium', 108),
  ('aptitude', 'logical', 'Analogy', 'Bird : Fly :: Fish : ?', '["Run", "Crawl", "Walk", "Swim"]'::jsonb, 3, 'A bird moves by flying and a fish moves by swimming.', 'Easy', 109),
  ('aptitude', 'logical', 'Analogy', 'Doctor : Hospital :: Teacher : ?', '["Bank", "Factory", "Court", "School"]'::jsonb, 3, 'A doctor works in a hospital and a teacher works in a school.', 'Easy', 110),
  ('aptitude', 'logical', 'Analogy', 'Hot : Cold :: Day : ?', '["Light", "Night", "Morning", "Sun"]'::jsonb, 1, 'Each pair consists of opposites.', 'Easy', 111),
  ('aptitude', 'logical', 'Classification', 'Choose the odd one out: Apple, Banana, Carrot, Mango.', '["Carrot", "Mango", "Apple", "Banana"]'::jsonb, 0, 'Carrot is a vegetable; the others are fruits.', 'Easy', 112),
  ('aptitude', 'logical', 'Classification', 'Choose the odd one out: 2, 3, 5, 9.', '["2", "3", "5", "9"]'::jsonb, 3, '2, 3 and 5 are prime; 9 is not.', 'Easy', 113),
  ('aptitude', 'logical', 'Classification', 'Choose the odd one out: Square, Triangle, Circle, Cube.', '["Square", "Cube", "Circle", "Triangle"]'::jsonb, 1, 'A cube is three-dimensional; the others are flat shapes.', 'Easy', 114),
  ('aptitude', 'logical', 'Logical Sequence', 'Arrange in a logical order: 1. Fruit 2. Flower 3. Seed 4. Plant', '["3, 4, 2, 1", "3, 2, 4, 1", "4, 3, 2, 1", "1, 2, 3, 4"]'::jsonb, 0, 'Seed -> Plant -> Flower -> Fruit.', 'Easy', 115),
  ('aptitude', 'logical', 'Logical Sequence', 'Find the next day in the pattern: Monday, Wednesday, Friday, ?', '["Saturday", "Sunday", "Monday", "Tuesday"]'::jsonb, 1, 'Every second day: the day after Friday + 1 is Sunday.', 'Easy', 116),
  ('aptitude', 'logical', 'Logical Sequence', 'Find the next month in the pattern: Jan, Mar, May, Jul, ?', '["Oct", "Aug", "Nov", "Sep"]'::jsonb, 3, 'Every second month: Jul + 2 = Sep.', 'Easy', 117),
  ('aptitude', 'verbal', 'Synonyms', 'Choose the word closest in meaning to ABUNDANT.', '["Plentiful", "Rigid", "Scarce", "Tiny"]'::jsonb, 0, 'Abundant means existing in large quantities.', 'Easy', 118),
  ('aptitude', 'verbal', 'Synonyms', 'Choose the word closest in meaning to CANDID.', '["Secretive", "Shy", "Rude", "Frank"]'::jsonb, 3, 'A candid person is open and honest.', 'Easy', 119),
  ('aptitude', 'verbal', 'Synonyms', 'Choose the word closest in meaning to METICULOUS.', '["Hasty", "Lazy", "Thorough", "Careless"]'::jsonb, 2, 'Meticulous means showing great attention to detail.', 'Medium', 120),
  ('aptitude', 'verbal', 'Synonyms', 'Choose the word closest in meaning to BENEVOLENT.', '["Cruel", "Kind", "Proud", "Greedy"]'::jsonb, 1, 'Benevolent means well-meaning and kindly.', 'Easy', 121),
  ('aptitude', 'verbal', 'Synonyms', 'Choose the word closest in meaning to OBSOLETE.', '["Modern", "Fragile", "Outdated", "Popular"]'::jsonb, 2, 'Obsolete means no longer in use or out of date.', 'Easy', 122),
  ('aptitude', 'verbal', 'Sentence Correction', 'Choose the grammatically correct sentence (subject-verb agreement).', '["Each of the players has received a medal.", "Each of the players have received a medal.", "Each of the player have received a medal.", "Each of the players are receiving a medal."]'::jsonb, 0, '''Each'' is singular, so it takes ''has''.', 'Easy', 123),
  ('aptitude', 'verbal', 'Sentence Correction', 'Choose the grammatically correct sentence (auxiliary verbs).', '["He don''t like coffee.", "He doesn''t likes coffee.", "He doesn''t like coffee.", "He not like coffee."]'::jsonb, 2, 'A third-person singular subject takes ''doesn''t'' followed by the base verb.', 'Easy', 124),
  ('aptitude', 'verbal', 'Sentence Correction', 'Choose the grammatically correct sentence (prepositions of time).', '["She has been working here since five years.", "She has been working here for five years.", "She is working here from five years.", "She has worked here since five years."]'::jsonb, 1, '''For'' is used with a period of time; ''since'' with a starting point.', 'Medium', 125),
  ('aptitude', 'verbal', 'Sentence Correction', 'Choose the grammatically correct sentence (gerunds).', '["I am looking forward to meet you.", "I am looking forward to meeting you.", "I am looking forward for meeting you.", "I look forward to meet you."]'::jsonb, 1, 'In ''look forward to'', ''to'' is a preposition and is followed by the -ing form.', 'Medium', 126),
  ('aptitude', 'verbal', 'Sentence Correction', 'Choose the grammatically correct sentence (conditionals).', '["If I would have known, I would have come.", "If I knew, I would have come.", "If I had known, I would have come.", "If I have known, I would come."]'::jsonb, 2, 'Third conditional: ''If + past perfect, would have + past participle''.', 'Medium', 127),
  ('aptitude', 'verbal', 'Reading Comprehension', 'Passage: ''Honey bees communicate the location of food through a waggle dance. The angle of the dance relative to the vertical shows direction, and its duration shows distance.'' What does the duration of the dance indicate?', '["Number of bees", "Quality of the food", "Direction of the food", "Distance to the food"]'::jsonb, 3, 'The passage says duration shows distance.', 'Easy', 128),
  ('aptitude', 'verbal', 'Reading Comprehension', 'Passage: ''Regular exercise improves mood by releasing endorphins, and it also improves sleep quality.'' What is the main idea?', '["Sleep matters more than exercise", "Exercise benefits both mood and sleep", "Endorphins are harmful", "Exercise is difficult to maintain"]'::jsonb, 1, 'The passage lists two benefits of regular exercise.', 'Easy', 129),
  ('aptitude', 'verbal', 'Reading Comprehension', 'Passage: ''Although the city''s metro reduced traffic congestion, ticket prices have limited its use among low-income workers.'' What limited the metro''s use among low-income workers?', '["Noise", "Lack of stations", "Traffic congestion", "Ticket prices"]'::jsonb, 3, 'The passage names ticket prices as the limiting factor.', 'Medium', 130),
  ('aptitude', 'verbal', 'Error Spotting', 'Find the part with an error: ''He go / to school / every day. / No error''', '["He go", "to school", "every day", "No error"]'::jsonb, 0, 'A singular subject needs ''goes''.', 'Easy', 131),
  ('aptitude', 'verbal', 'Error Spotting', 'Find the part with an error: ''Each of the boys / have finished / their homework. / No error''', '["Each of the boys", "have finished", "their homework", "No error"]'::jsonb, 1, '''Each'' is singular, so the verb should be ''has finished''.', 'Medium', 132),
  ('aptitude', 'verbal', 'Error Spotting', 'Find the part with an error: ''She is / more smarter / than her sister. / No error''', '["She is", "more smarter", "than her sister", "No error"]'::jsonb, 1, '''Smarter'' is already comparative; use ''smarter'' or ''more intelligent''.', 'Easy', 133),
  ('aptitude', 'verbal', 'Antonyms', 'Choose the word opposite in meaning to ANCIENT.', '["Modern", "Old", "Historic", "Weak"]'::jsonb, 0, 'Ancient means very old; modern is its opposite.', 'Easy', 134),
  ('aptitude', 'verbal', 'Antonyms', 'Choose the word opposite in meaning to GENEROUS.', '["Rich", "Stingy", "Brave", "Kind"]'::jsonb, 1, 'Generous means giving freely; stingy is unwilling to give.', 'Easy', 135),
  ('aptitude', 'verbal', 'Antonyms', 'Choose the word opposite in meaning to EXPAND.', '["Extend", "Contract", "Grow", "Stretch"]'::jsonb, 1, 'To expand is to become larger; to contract is to become smaller.', 'Easy', 136),
  ('aptitude', 'verbal', 'Vocabulary', 'What does EPHEMERAL mean?', '["Very old", "Mysterious", "Lasting a very short time", "Extremely large"]'::jsonb, 2, 'Ephemeral things last only briefly.', 'Medium', 137),
  ('aptitude', 'verbal', 'Vocabulary', 'What does UBIQUITOUS mean?', '["Hidden", "Found everywhere", "Rare", "Dangerous"]'::jsonb, 1, 'Ubiquitous means present or seen everywhere.', 'Medium', 138),
  ('aptitude', 'verbal', 'Vocabulary', 'What does PRAGMATIC mean?', '["Practical and realistic", "Dreamy", "Angry", "Careless"]'::jsonb, 0, 'A pragmatic approach deals with things sensibly and realistically.', 'Easy', 139),
  ('aptitude', 'verbal', 'Para Jumbles', 'Arrange the sentences: P. He picked up the phone. Q. The phone rang. R. It was his mother. S. He smiled.', '["QPRS", "PQRS", "QRPS", "SQPR"]'::jsonb, 0, 'The phone rings, he answers, discovers the caller, then smiles.', 'Easy', 140),
  ('aptitude', 'verbal', 'Para Jumbles', 'Arrange the parts: P. and she was thrilled. Q. Meera cleared the exam R. after months of effort', '["PQR", "QRP", "RQP", "QPR"]'::jsonb, 1, 'Meera cleared the exam after months of effort and she was thrilled.', 'Easy', 141),
  ('aptitude', 'verbal', 'Para Jumbles', 'Arrange the steps: P. Then add the pasta. Q. First, boil the water. R. Finally, serve it hot. S. Add salt to the water.', '["QSPR", "SQPR", "QPSR", "PQSR"]'::jsonb, 0, 'Boil water, add salt, add pasta, serve.', 'Easy', 142),
  ('aptitude', 'verbal', 'Fill in the Blanks', 'She is very good ___ mathematics.', '["in", "for", "at", "on"]'::jsonb, 2, 'The correct collocation is ''good at''.', 'Easy', 143),
  ('aptitude', 'verbal', 'Fill in the Blanks', 'He has been absent ___ Monday.', '["by", "for", "from", "since"]'::jsonb, 3, '''Since'' marks the starting point of a period.', 'Easy', 144),
  ('aptitude', 'verbal', 'Fill in the Blanks', 'She insisted ___ paying the bill.', '["at", "for", "to", "on"]'::jsonb, 3, 'The verb ''insist'' takes the preposition ''on''.', 'Medium', 145),
  ('aptitude', 'verbal', 'Sentence Completion', 'Despite the heavy rain, the match ___ as scheduled.', '["got postponed", "went ahead", "was cancelled", "never started"]'::jsonb, 1, '''Despite'' signals a contrast with the rain, so the match continued.', 'Easy', 146),
  ('aptitude', 'verbal', 'Sentence Completion', 'He worked hard; ___, he passed with distinction.', '["however", "otherwise", "meanwhile", "consequently"]'::jsonb, 3, 'The second clause is a result of the first.', 'Easy', 147),
  ('aptitude', 'verbal', 'Sentence Completion', 'Not only was the food delicious, ___ the service was excellent.', '["but also", "and also", "also", "as well"]'::jsonb, 0, '''Not only ... but also'' is the correlative pair.', 'Medium', 148),
  ('technical', 'programming', 'C', 'Which data type is commonly used to store a single character in C?', '["int", "float", "double", "char"]'::jsonb, 3, 'The char type holds one character.', 'Easy', 149),
  ('technical', 'programming', 'C', 'Which operator is used to access the value stored at a pointer''s address in C?', '["*", "%", "&", "->"]'::jsonb, 0, 'The dereference operator * gives the value the pointer points to.', 'Easy', 150),
  ('technical', 'programming', 'C', 'What does printf("%d", 5/2); print in C?', '["2", "3", "Compilation error", "2.5"]'::jsonb, 0, 'Both operands are integers, so integer division truncates 2.5 to 2.', 'Easy', 151),
  ('technical', 'programming', 'C', 'Which header file declares printf() in C?', '["stdio.h", "string.h", "stdlib.h", "math.h"]'::jsonb, 0, 'printf is part of the standard I/O library declared in stdio.h.', 'Easy', 152),
  ('technical', 'programming', 'C', 'What is the size of an int on most modern C compilers?', '["1 byte", "2 bytes", "4 bytes", "8 bytes"]'::jsonb, 2, 'On common 32-bit and 64-bit platforms an int is 4 bytes.', 'Easy', 153),
  ('technical', 'programming', 'C++', 'Which operator allocates memory dynamically in C++?', '["new", "alloc", "malloc", "create"]'::jsonb, 0, 'new allocates and constructs an object on the heap.', 'Easy', 154),
  ('technical', 'programming', 'C++', 'Which object is used to print output to the console in C++?', '["print", "cprint", "echo", "cout"]'::jsonb, 3, 'cout is the standard output stream from <iostream>.', 'Easy', 155),
  ('technical', 'programming', 'C++', 'Which of the following is NOT an access specifier in C++?', '["public", "friend", "protected", "private"]'::jsonb, 1, 'friend is a keyword granting access, not an access specifier.', 'Medium', 156),
  ('technical', 'programming', 'C++', 'Defining several functions with the same name but different parameter lists is called:', '["Inheritance", "Encapsulation", "Function overriding", "Function overloading"]'::jsonb, 3, 'Overloading differs by parameters; overriding redefines a base-class method.', 'Easy', 157),
  ('technical', 'programming', 'C++', 'Which STL container stores unique elements in sorted order?', '["vector", "deque", "list", "set"]'::jsonb, 3, 'std::set keeps unique keys sorted.', 'Easy', 158),
  ('technical', 'programming', 'Java', 'Which keyword is used to inherit a class in Java?', '["inherits", "extends", "super", "implements"]'::jsonb, 1, 'A class extends another class; it implements an interface.', 'Easy', 159),
  ('technical', 'programming', 'Java', 'What is the correct signature of the Java program entry point?', '["public static void main(String[] args)", "public void main()", "void main(String[] args)", "static main(String args)"]'::jsonb, 0, 'The JVM looks for this exact public static main method.', 'Easy', 160),
  ('technical', 'programming', 'Java', 'Which of the following is NOT a primitive data type in Java?', '["String", "char", "int", "boolean"]'::jsonb, 0, 'String is a class; int, boolean and char are primitives.', 'Easy', 161),
  ('technical', 'programming', 'Java', 'Which collection does NOT allow duplicate elements?', '["HashSet", "LinkedList", "ArrayList", "Vector"]'::jsonb, 0, 'A Set stores unique elements.', 'Easy', 162),
  ('technical', 'programming', 'Java', 'Which keyword prevents a method from being overridden in a subclass?', '["final", "static", "const", "abstract"]'::jsonb, 0, 'A final method cannot be overridden.', 'Medium', 163),
  ('technical', 'programming', 'Python', 'Which keyword is used to define a function in Python?', '["function", "func", "define", "def"]'::jsonb, 3, 'Python uses def to define functions.', 'Easy', 164),
  ('technical', 'programming', 'Python', 'What does print(type([])) display in Python?', '["<class ''list''>", "<class ''dict''>", "<class ''set''>", "<class ''tuple''>"]'::jsonb, 0, '[] is an empty list literal.', 'Easy', 165),
  ('technical', 'programming', 'Python', 'Which of these Python types is immutable?', '["dict", "tuple", "set", "list"]'::jsonb, 1, 'Tuples cannot be modified after creation.', 'Easy', 166),
  ('technical', 'programming', 'Python', 'What does len("PrepNest") return?', '["7", "8", "9", "10"]'::jsonb, 1, 'The string has 8 characters.', 'Easy', 167),
  ('technical', 'programming', 'Python', 'What sequence does range(3) produce?', '["1, 2, 3", "0, 1, 2, 3", "0, 1, 2", "1, 2"]'::jsonb, 2, 'range(n) starts at 0 and stops before n.', 'Easy', 168),
  ('technical', 'cs-core', 'Data Structures', 'Which data structure follows First-In-First-Out (FIFO) order?', '["Stack", "Queue", "Heap", "Tree"]'::jsonb, 1, 'A queue serves elements in the order they arrived.', 'Easy', 169),
  ('technical', 'cs-core', 'Data Structures', 'Which stack operation removes the top element?', '["push", "enqueue", "peek", "pop"]'::jsonb, 3, 'pop removes and returns the top element.', 'Easy', 170),
  ('technical', 'cs-core', 'Data Structures', 'What is the time complexity of accessing an array element by index?', '["O(log n)", "O(1)", "O(n)", "O(n^2)"]'::jsonb, 1, 'Array indexing is a direct address calculation.', 'Easy', 171),
  ('technical', 'cs-core', 'Data Structures', 'Which traversal of a binary search tree visits the keys in sorted order?', '["Preorder", "Level-order", "Postorder", "Inorder"]'::jsonb, 3, 'Inorder visits left, node, right, giving ascending keys.', 'Medium', 172),
  ('technical', 'cs-core', 'Data Structures', 'Which data structure does Breadth-First Search (BFS) use?', '["Queue", "Heap", "Stack", "Binary tree"]'::jsonb, 0, 'BFS explores level by level using a queue.', 'Easy', 173),
  ('technical', 'cs-core', 'Algorithms', 'What is the worst-case time complexity of binary search?', '["O(n log n)", "O(n)", "O(log n)", "O(1)"]'::jsonb, 2, 'The search range halves with each comparison.', 'Easy', 174),
  ('technical', 'cs-core', 'Algorithms', 'Which sorting algorithm is based on divide and conquer and runs in O(n log n) time?', '["Bubble sort", "Selection sort", "Merge sort", "Insertion sort"]'::jsonb, 2, 'Merge sort splits, sorts and merges.', 'Easy', 175),
  ('technical', 'cs-core', 'Algorithms', 'Which of these algorithms is a greedy algorithm?', '["Longest common subsequence", "Dijkstra''s shortest path", "Floyd-Warshall", "Matrix chain multiplication"]'::jsonb, 1, 'Dijkstra repeatedly picks the closest unvisited vertex; the others use dynamic programming.', 'Medium', 176),
  ('technical', 'cs-core', 'Algorithms', 'What is the worst-case time complexity of quicksort?', '["O(n)", "O(n log n)", "O(log n)", "O(n^2)"]'::jsonb, 3, 'Poor pivot choices (e.g. already sorted input) lead to O(n^2).', 'Medium', 177),
  ('technical', 'cs-core', 'Algorithms', 'Which data structure is used (explicitly or via recursion) by Depth-First Search?', '["Hash table", "Queue", "Heap", "Stack"]'::jsonb, 3, 'DFS goes deep first and backtracks using a stack.', 'Easy', 178),
  ('technical', 'cs-core', 'DBMS', 'Which normal form removes partial dependency?', '["2NF", "BCNF", "1NF", "3NF"]'::jsonb, 0, 'Second Normal Form removes partial dependency on part of a composite key.', 'Medium', 179),
  ('technical', 'cs-core', 'DBMS', 'What is the main property of a primary key?', '["It allows duplicate values", "It must be composite", "It uniquely identifies each row", "It can contain NULL"]'::jsonb, 2, 'A primary key is unique and non-null.', 'Easy', 180),
  ('technical', 'cs-core', 'DBMS', 'In the ACID properties of transactions, what does ''A'' stand for?', '["Authorization", "Accuracy", "Availability", "Atomicity"]'::jsonb, 3, 'Atomicity means a transaction is all-or-nothing.', 'Easy', 181),
  ('technical', 'cs-core', 'DBMS', 'Which of the following is a DDL command?', '["UPDATE", "CREATE", "SELECT", "DELETE"]'::jsonb, 1, 'CREATE defines structure; SELECT/UPDATE/DELETE work on data.', 'Easy', 182),
  ('technical', 'cs-core', 'DBMS', 'What is the purpose of a foreign key?', '["To link two tables and enforce referential integrity", "To speed up all queries", "To encrypt a column", "To store backups"]'::jsonb, 0, 'A foreign key references a primary key in another table.', 'Easy', 183),
  ('technical', 'cs-core', 'Operating Systems', 'Which CPU scheduling algorithm is non-preemptive?', '["Round Robin", "Preemptive priority", "First Come First Served (FCFS)", "Shortest Remaining Time First"]'::jsonb, 2, 'FCFS lets a process run until it finishes or blocks.', 'Easy', 184),
  ('technical', 'cs-core', 'Operating Systems', 'Which of the following is a necessary condition for deadlock?', '["Paging", "Spooling", "Aging", "Mutual exclusion"]'::jsonb, 3, 'The four conditions are mutual exclusion, hold and wait, no preemption and circular wait.', 'Medium', 185),
  ('technical', 'cs-core', 'Operating Systems', 'Virtual memory is commonly implemented using:', '["Buffering", "Spooling", "Paging", "Polling"]'::jsonb, 2, 'Demand paging lets a process use more memory than is physically present.', 'Easy', 186),
  ('technical', 'cs-core', 'Operating Systems', 'A program in execution is called a:', '["Compiler", "Shell", "Process", "Kernel"]'::jsonb, 2, 'A process is an instance of a running program.', 'Easy', 187),
  ('technical', 'cs-core', 'Operating Systems', 'Round Robin scheduling gives each process a fixed:', '["Burst length", "Page size", "Time quantum", "Priority"]'::jsonb, 2, 'Each process runs for one time quantum before the next is scheduled.', 'Easy', 188),
  ('technical', 'cs-core', 'Computer Networks', 'How many layers does the OSI model have?', '["4", "5", "7", "9"]'::jsonb, 2, 'Physical, data link, network, transport, session, presentation, application.', 'Easy', 189),
  ('technical', 'cs-core', 'Computer Networks', 'What is the default port for HTTP?', '["21", "25", "80", "443"]'::jsonb, 2, 'HTTP uses port 80; HTTPS uses 443.', 'Easy', 190),
  ('technical', 'cs-core', 'Computer Networks', 'Which protocol translates domain names into IP addresses?', '["ARP", "DHCP", "FTP", "DNS"]'::jsonb, 3, 'The Domain Name System maps names to IP addresses.', 'Easy', 191),
  ('technical', 'cs-core', 'Computer Networks', 'Which IP version uses 128-bit addresses?', '["IPv6", "ICMP", "IPv4", "ARP"]'::jsonb, 0, 'IPv4 is 32-bit; IPv6 is 128-bit.', 'Easy', 192),
  ('technical', 'cs-core', 'Computer Networks', 'Which transport-layer protocol is connection-oriented?', '["IP", "ICMP", "TCP", "UDP"]'::jsonb, 2, 'TCP establishes a connection and guarantees ordered delivery.', 'Easy', 193),
  ('technical', 'cs-core', 'OOP', 'Wrapping data and the methods that operate on it into a single unit is called:', '["Polymorphism", "Abstraction", "Inheritance", "Encapsulation"]'::jsonb, 3, 'Encapsulation bundles data and behaviour and restricts direct access.', 'Easy', 194),
  ('technical', 'cs-core', 'OOP', 'The ability of an object to take many forms is called:', '["Encapsulation", "Inheritance", "Polymorphism", "Abstraction"]'::jsonb, 2, 'Polymorphism lets one interface behave differently for different types.', 'Easy', 195),
  ('technical', 'cs-core', 'OOP', 'Deriving a new class from an existing class is called:', '["Compilation", "Overloading", "Inheritance", "Linking"]'::jsonb, 2, 'The derived class reuses the base class''s members.', 'Easy', 196),
  ('technical', 'cs-core', 'OOP', 'Showing only essential features while hiding implementation details is called:', '["Iteration", "Recursion", "Inheritance", "Abstraction"]'::jsonb, 3, 'Abstraction exposes what an object does, not how.', 'Easy', 197),
  ('technical', 'cs-core', 'OOP', 'What is a class in OOP?', '["A single method", "A blueprint for creating objects", "A running instance of a program", "A package of files"]'::jsonb, 1, 'Objects are instances created from a class.', 'Easy', 198),
  ('technical', 'cs-core', 'Software Engineering', 'Which is the first phase of the Software Development Life Cycle (SDLC)?', '["Deployment", "Testing", "Maintenance", "Requirement analysis"]'::jsonb, 3, 'Requirements must be understood before design and coding.', 'Easy', 199),
  ('technical', 'cs-core', 'Software Engineering', 'Which model delivers software in short iterations with frequent feedback?', '["Big Bang", "Agile", "Waterfall", "V-model"]'::jsonb, 1, 'Agile works in short sprints with continuous feedback.', 'Easy', 200),
  ('technical', 'cs-core', 'Software Engineering', 'Testing individual functions or modules in isolation is called:', '["Unit testing", "Integration testing", "System testing", "Acceptance testing"]'::jsonb, 0, 'Unit tests check the smallest testable parts.', 'Easy', 201),
  ('technical', 'webdev', 'HTML', 'Which tag defines the largest heading in HTML?', '["<h6>", "<head>", "<h1>", "<title>"]'::jsonb, 2, '<h1> is the highest-level heading.', 'Easy', 202),
  ('technical', 'webdev', 'HTML', 'Which tag creates a hyperlink in HTML?', '["<a>", "<href>", "<link>", "<url>"]'::jsonb, 0, 'The anchor tag <a href=...> creates links.', 'Easy', 203),
  ('technical', 'webdev', 'HTML', 'Which attribute provides alternative text for an image?', '["caption", "title", "alt", "name"]'::jsonb, 2, 'The alt attribute is shown if the image fails to load and is read by screen readers.', 'Easy', 204),
  ('technical', 'webdev', 'HTML', 'Which HTML5 semantic element is meant for navigation links?', '["<menu-bar>", "<navigate>", "<links>", "<nav>"]'::jsonb, 3, '<nav> marks a block of navigation links.', 'Easy', 205),
  ('technical', 'webdev', 'HTML', 'Which tag creates an ordered (numbered) list?', '["<ul>", "<li>", "<dl>", "<ol>"]'::jsonb, 3, '<ol> is an ordered list; <ul> is unordered.', 'Easy', 206),
  ('technical', 'webdev', 'CSS', 'Which CSS property changes the text colour?', '["foreground", "color", "text-color", "font-color"]'::jsonb, 1, 'color sets the foreground colour of text.', 'Easy', 207),
  ('technical', 'webdev', 'CSS', 'Which selector targets elements with class "box"?', '[".box", "#box", "*box", "box"]'::jsonb, 0, 'A leading dot selects a class; # selects an id.', 'Easy', 208),
  ('technical', 'webdev', 'CSS', 'In the CSS box model, what is the order from the inside out?', '["Content, padding, border, margin", "Margin, border, padding, content", "Content, border, padding, margin", "Padding, content, margin, border"]'::jsonb, 0, 'Content is surrounded by padding, then border, then margin.', 'Medium', 209),
  ('technical', 'webdev', 'CSS', 'Which display value turns an element into a flex container?', '["float", "block", "inline-block", "flex"]'::jsonb, 3, 'display: flex enables the flexbox layout.', 'Easy', 210),
  ('technical', 'webdev', 'CSS', 'Which property makes text bold?', '["font-style", "bold", "font-weight", "text-weight"]'::jsonb, 2, 'font-weight: bold (or 700) sets boldness.', 'Easy', 211),
  ('technical', 'webdev', 'JavaScript', 'Which keyword declares a block-scoped variable that can be reassigned?', '["static", "let", "const", "var"]'::jsonb, 1, 'let is block scoped and reassignable; const cannot be reassigned.', 'Easy', 212),
  ('technical', 'webdev', 'JavaScript', 'What does typeof null return in JavaScript?', '["\"null\"", "\"undefined\"", "\"number\"", "\"object\""]'::jsonb, 3, 'This is a long-standing quirk of the language.', 'Medium', 213),
  ('technical', 'webdev', 'JavaScript', 'Which operator checks both value and type equality?', '["==", "!=", "===", "="]'::jsonb, 2, '=== is strict equality without type coercion.', 'Easy', 214),
  ('technical', 'webdev', 'JavaScript', 'Which array method adds an element to the end of an array?', '["unshift()", "shift()", "push()", "pop()"]'::jsonb, 2, 'push appends; unshift adds to the front.', 'Easy', 215),
  ('technical', 'webdev', 'JavaScript', 'Which keyword declares a constant binding?', '["var", "let", "const", "static"]'::jsonb, 2, 'const creates a binding that cannot be reassigned.', 'Easy', 216),
  ('technical', 'webdev', 'React', 'Which hook adds state to a function component?', '["useMemo", "useRef", "useEffect", "useState"]'::jsonb, 3, 'useState returns a state value and its setter.', 'Easy', 217),
  ('technical', 'webdev', 'React', 'What does JSX stand for?', '["Java Syntax Extension", "JavaScript XML", "JavaScript Extra", "JSON XML"]'::jsonb, 1, 'JSX is an XML-like syntax extension for JavaScript.', 'Easy', 218),
  ('technical', 'webdev', 'React', 'Props passed to a React component are:', '["Private state", "Read-only", "Global variables", "Mutable by the child"]'::jsonb, 1, 'A component must never modify its own props.', 'Easy', 219),
  ('technical', 'webdev', 'React', 'Which hook is used to run side effects such as data fetching?', '["useReducer", "useState", "useEffect", "useContext"]'::jsonb, 2, 'useEffect runs after render and handles side effects.', 'Easy', 220),
  ('technical', 'webdev', 'React', 'What is the purpose of the key prop when rendering lists?', '["To identify list items between renders", "To style list items", "To handle click events", "To define routes"]'::jsonb, 0, 'Keys let React match items across updates efficiently.', 'Medium', 221),
  ('technical', 'webdev', 'Node.js', 'What is Node.js?', '["A CSS framework", "A PHP framework", "A JavaScript runtime built on Chrome''s V8 engine", "A relational database"]'::jsonb, 2, 'Node.js runs JavaScript outside the browser.', 'Easy', 222),
  ('technical', 'webdev', 'Node.js', 'Which tool is the default package manager for Node.js?', '["gem", "npm", "pip", "nuget"]'::jsonb, 1, 'npm installs and manages JavaScript packages.', 'Easy', 223),
  ('technical', 'webdev', 'Node.js', 'Which built-in module is used to create an HTTP server in Node.js?', '["http", "path", "os", "fs"]'::jsonb, 0, 'require(''http'').createServer(...) creates a server.', 'Medium', 224),
  ('technical', 'webdev', 'REST APIs', 'Which HTTP method is normally used to retrieve a resource?', '["PUT", "DELETE", "POST", "GET"]'::jsonb, 3, 'GET reads data without changing it.', 'Easy', 225),
  ('technical', 'webdev', 'REST APIs', 'What does HTTP status code 404 mean?', '["OK", "Moved Permanently", "Internal Server Error", "Not Found"]'::jsonb, 3, 'The server cannot find the requested resource.', 'Easy', 226),
  ('technical', 'webdev', 'REST APIs', 'What does it mean that REST is stateless?', '["Each request carries all the information needed to process it", "Connections are never closed", "The server stores a session for each client", "Only XML can be used"]'::jsonb, 0, 'The server keeps no client context between requests.', 'Medium', 227),
  ('technical', 'database', 'SQL', 'Which SQL clause filters rows before grouping?', '["GROUP BY", "HAVING", "ORDER BY", "WHERE"]'::jsonb, 3, 'WHERE filters rows before GROUP BY; HAVING filters groups afterwards.', 'Easy', 228),
  ('technical', 'database', 'SQL', 'Which keyword removes duplicate rows from a SELECT result?', '["DIFFERENT", "REMOVE", "DISTINCT", "UNIQUE"]'::jsonb, 2, 'SELECT DISTINCT returns only unique rows.', 'Easy', 229),
  ('technical', 'database', 'SQL', 'Which aggregate function returns the number of rows?', '["SUM()", "COUNT()", "TOTAL()", "NUMBER()"]'::jsonb, 1, 'COUNT(*) counts rows.', 'Easy', 230),
  ('technical', 'database', 'SQL', 'Which join returns only rows that have matching values in both tables?', '["CROSS JOIN", "FULL JOIN", "LEFT JOIN", "INNER JOIN"]'::jsonb, 3, 'INNER JOIN keeps only matching rows.', 'Medium', 231),
  ('technical', 'database', 'SQL', 'Which clause sorts the result in descending order of a column?', '["ARRANGE column DESC", "SORT BY column DESC", "GROUP BY column DESC", "ORDER BY column DESC"]'::jsonb, 3, 'ORDER BY ... DESC sorts from highest to lowest.', 'Easy', 232),
  ('technical', 'database', 'MySQL', 'Which MySQL statement lists all databases on the server?', '["SHOW DATABASES;", "SELECT DATABASES;", "DISPLAY DB;", "LIST DATABASES;"]'::jsonb, 0, 'SHOW DATABASES is the MySQL command.', 'Easy', 233),
  ('technical', 'database', 'MySQL', 'What is the default storage engine in modern MySQL versions?', '["MyISAM", "Memory", "CSV", "InnoDB"]'::jsonb, 3, 'InnoDB supports transactions and foreign keys and is the default since MySQL 5.5.', 'Medium', 234),
  ('technical', 'database', 'MySQL', 'Which column attribute generates sequential numbers automatically in MySQL?', '["SERIAL_KEY", "AUTO_INCREMENT", "COUNTER", "AUTONUM"]'::jsonb, 1, 'AUTO_INCREMENT assigns the next integer on insert.', 'Easy', 235),
  ('technical', 'database', 'PostgreSQL', 'Which data type is commonly used for an auto-incrementing id in PostgreSQL?', '["COUNTER", "SERIAL", "AUTONUM", "AUTO_INCREMENT"]'::jsonb, 1, 'SERIAL (or identity columns) provides auto-incrementing integers.', 'Easy', 236),
  ('technical', 'database', 'PostgreSQL', 'What is PostgreSQL''s interactive command-line client called?', '["sqlite3", "mysql", "psql", "sqlcmd"]'::jsonb, 2, 'psql connects to PostgreSQL from the terminal.', 'Easy', 237),
  ('technical', 'database', 'PostgreSQL', 'Which PostgreSQL type stores JSON in an indexable binary format?', '["BLOB", "BSON", "JSONB", "JSONX"]'::jsonb, 2, 'JSONB stores a decomposed binary form that supports indexing.', 'Medium', 238),
  ('technical', 'database', 'Database Design', 'What does ER stand for in an ER diagram?', '["Easy Reference", "Extended Relation", "Entity-Relationship", "Entity-Record"]'::jsonb, 2, 'ER diagrams model entities and the relationships between them.', 'Easy', 239),
  ('technical', 'database', 'Database Design', 'What is the main purpose of normalization?', '["To increase redundancy", "To reduce data redundancy", "To encrypt data", "To speed up networks"]'::jsonb, 1, 'Normalization organizes data to avoid duplication and anomalies.', 'Easy', 240),
  ('technical', 'database', 'Database Design', 'How is a many-to-many relationship usually implemented?', '["With a junction (bridge) table", "With a view", "With an index", "With a single extra column"]'::jsonb, 0, 'A junction table holds foreign keys to both sides.', 'Medium', 241),
  ('technical', 'other', 'Git & GitHub', 'Which command creates a new Git repository?', '["git init", "git new", "git start", "git create"]'::jsonb, 0, 'git init initialises a repository in the current folder.', 'Easy', 242),
  ('technical', 'other', 'Git & GitHub', 'Which command uploads local commits to a remote repository?', '["git push", "git merge", "git pull", "git fetch"]'::jsonb, 0, 'git push sends commits to the remote.', 'Easy', 243),
  ('technical', 'other', 'Git & GitHub', 'What does git clone do?', '["Deletes a branch", "Copies a remote repository to your machine", "Merges two branches", "Stages all files"]'::jsonb, 1, 'git clone downloads the full repository and its history.', 'Easy', 244),
  ('technical', 'other', 'Cloud Basics', 'What does IaaS provide?', '["Virtualized computing infrastructure", "Only software licences", "Ready-made end-user applications", "Only a programming language"]'::jsonb, 0, 'Infrastructure as a Service gives virtual machines, storage and networking.', 'Easy', 245),
  ('technical', 'other', 'Cloud Basics', 'Which of these is an example of SaaS?', '["Gmail", "Kubernetes", "Amazon EC2", "Docker"]'::jsonb, 0, 'Software as a Service delivers a finished application over the internet.', 'Easy', 246),
  ('technical', 'other', 'Cloud Basics', 'What is the main idea of pay-as-you-go pricing in the cloud?', '["You buy hardware upfront", "You pay only for the resources you use", "You pay a fixed lifetime fee", "Services are always free"]'::jsonb, 1, 'Cloud billing is usage-based.', 'Easy', 247),
  ('technical', 'other', 'AI/ML Basics', 'Supervised learning is trained using:', '["Random noise", "Labelled data", "No data", "Unlabelled data only"]'::jsonb, 1, 'Each training example comes with the correct answer.', 'Easy', 248),
  ('technical', 'other', 'AI/ML Basics', 'What is overfitting?', '["A model trains too quickly", "A model is too simple to learn anything", "A model performs well on training data but poorly on new data", "A model uses too little memory"]'::jsonb, 2, 'An overfit model has memorised the training set.', 'Medium', 249),
  ('technical', 'other', 'AI/ML Basics', 'Which of these algorithms is used for classification?', '["Principal component analysis", "K-means clustering", "Apriori", "Logistic regression"]'::jsonb, 3, 'Logistic regression predicts class labels; K-means and PCA are unsupervised.', 'Medium', 250),
  ('technical', 'other', 'Cyber Security Basics', 'What is phishing?', '["Tricking people into revealing sensitive information through fake messages or sites", "Scanning a network for open ports", "Encrypting files for ransom", "Overloading a server with traffic"]'::jsonb, 0, 'Phishing relies on deception, usually email or fake websites.', 'Easy', 251),
  ('technical', 'other', 'Cyber Security Basics', 'Which protocol encrypts web traffic between a browser and a site?', '["Telnet", "FTP", "HTTPS (TLS)", "SMTP"]'::jsonb, 2, 'HTTPS is HTTP over TLS.', 'Easy', 252),
  ('technical', 'other', 'Cyber Security Basics', 'Which password is the strongest?', '["A short, memorable word", "password123", "A long, unique mix of letters, numbers and symbols", "Your birth date"]'::jsonb, 2, 'Length, variety and uniqueness make a password hard to guess.', 'Easy', 253),
  ('hr', 'hr-sjt', 'Situational Judgement', 'A teammate misses a deadline that affects your part of the project. What is the best first step?', '["Quietly do their work and say nothing", "Report them to the manager immediately", "Complain about it to other colleagues", "Talk to them privately to understand the problem and offer help"]'::jsonb, 3, 'Understanding the cause first and offering support keeps the relationship and the project on track.', 'Medium', 254),
  ('hr', 'hr-sjt', 'Situational Judgement', 'You disagree with your manager''s approach to a task. What should you do?', '["Stop working on the task", "Argue about it in front of the whole team", "Ignore the instruction and do it your way", "Respectfully share your view with reasons, then support the final decision"]'::jsonb, 3, 'Constructive disagreement followed by commitment shows maturity.', 'Medium', 255),
  ('hr', 'hr-sjt', 'Situational Judgement', 'You notice a mistake in work you already delivered. What do you do?', '["Hope nobody notices", "Inform the stakeholder promptly and fix it", "Blame the tools you used", "Wait until someone else finds it"]'::jsonb, 1, 'Early honesty limits the damage and builds trust.', 'Medium', 256),
  ('hr', 'hr-sjt', 'Situational Judgement', 'You have two urgent tasks with the same deadline. What is the best approach?', '["Start both and finish neither properly", "Clarify priorities with your manager and communicate trade-offs", "Do only the easier one", "Pick one at random"]'::jsonb, 1, 'Aligning on priorities avoids wasted effort and surprises.', 'Medium', 257),
  ('hr', 'hr-sjt', 'Situational Judgement', 'A new team member is struggling while you are busy. What do you do?', '["Tell them to figure it out alone", "Point them to resources now and offer dedicated time later", "Do all their work for them", "Ignore the situation"]'::jsonb, 1, 'A brief pointer plus a scheduled follow-up helps without derailing your work.', 'Medium', 258),
  ('hr', 'common', 'Common HR', 'Tell me about yourself', '[]'::jsonb, null, null, 'Medium', 259),
  ('hr', 'common', 'Common HR', 'What are your strengths?', '[]'::jsonb, null, null, 'Medium', 260),
  ('hr', 'common', 'Common HR', 'What are your weaknesses?', '[]'::jsonb, null, null, 'Medium', 261),
  ('hr', 'common', 'Common HR', 'What are your career goals?', '[]'::jsonb, null, null, 'Medium', 262),
  ('hr', 'common', 'Common HR', 'Why should we hire you?', '[]'::jsonb, null, null, 'Medium', 263),
  ('hr', 'common', 'Common HR', 'Why this company?', '[]'::jsonb, null, null, 'Medium', 264),
  ('hr', 'behavioral', 'Behavioral', 'Describe a time you worked in a team', '[]'::jsonb, null, null, 'Medium', 265),
  ('hr', 'behavioral', 'Behavioral', 'Tell me about a time you showed leadership', '[]'::jsonb, null, null, 'Medium', 266),
  ('hr', 'behavioral', 'Behavioral', 'Describe a conflict you resolved', '[]'::jsonb, null, null, 'Medium', 267),
  ('hr', 'behavioral', 'Behavioral', 'Tell me about a failure and what you learned', '[]'::jsonb, null, null, 'Medium', 268),
  ('hr', 'behavioral', 'Behavioral', 'Describe your approach to problem solving', '[]'::jsonb, null, null, 'Medium', 269),
  ('hr', 'situational', 'Situational', 'How would you handle a disagreement with a teammate?', '[]'::jsonb, null, null, 'Medium', 270),
  ('hr', 'situational', 'Situational', 'What would you do if you found an ethical issue at work?', '[]'::jsonb, null, null, 'Medium', 271),
  ('hr', 'situational', 'Situational', 'How would you resolve conflict within your team?', '[]'::jsonb, null, null, 'Medium', 272),
  ('hr', 'situational', 'Situational', 'How do you handle a tight deadline?', '[]'::jsonb, null, null, 'Medium', 273),
  ('hr', 'freshers', 'Freshers', 'Tell me about your college experience', '[]'::jsonb, null, null, 'Medium', 274),
  ('hr', 'freshers', 'Freshers', 'Walk me through your best project', '[]'::jsonb, null, null, 'Medium', 275),
  ('hr', 'freshers', 'Freshers', 'Describe your internship experience', '[]'::jsonb, null, null, 'Medium', 276),
  ('hr', 'freshers', 'Freshers', 'What are your expectations from this role?', '[]'::jsonb, null, null, 'Medium', 277),
  ('interview', 'int-general', 'General Interview', 'Tell me about yourself.', '[]'::jsonb, null, null, 'Medium', 278),
  ('interview', 'int-general', 'General Interview', 'Why are you interested in the {role} role?', '[]'::jsonb, null, null, 'Medium', 279),
  ('interview', 'int-general', 'General Interview', 'Walk me through a project you''re most proud of.', '[]'::jsonb, null, null, 'Medium', 280),
  ('interview', 'int-general', 'General Interview', 'How do you approach debugging a difficult issue?', '[]'::jsonb, null, null, 'Medium', 281),
  ('interview', 'int-general', 'General Interview', 'Describe a time you had to learn something quickly.', '[]'::jsonb, null, null, 'Medium', 282),
  ('interview', 'int-general', 'General Interview', 'Where do you see yourself in the next few years?', '[]'::jsonb, null, null, 'Medium', 283),
  ('interview', 'int-technical', 'Technical Interview', 'Explain the difference between a stack and a queue.', '[]'::jsonb, null, null, 'Medium', 284),
  ('interview', 'int-technical', 'Technical Interview', 'How does a hash map achieve average O(1) lookup?', '[]'::jsonb, null, null, 'Medium', 285),
  ('interview', 'int-technical', 'Technical Interview', 'What happens when you type a URL into a browser?', '[]'::jsonb, null, null, 'Medium', 286),
  ('interview', 'int-technical', 'Technical Interview', 'Explain the concept of time complexity with an example.', '[]'::jsonb, null, null, 'Medium', 287),
  ('interview', 'int-technical', 'Technical Interview', 'How would you design a rate limiter?', '[]'::jsonb, null, null, 'Medium', 288),
  ('interview', 'int-hr', 'HR Interview', 'Tell me about yourself.', '[]'::jsonb, null, null, 'Medium', 289),
  ('interview', 'int-hr', 'HR Interview', 'What are your greatest strengths and weaknesses?', '[]'::jsonb, null, null, 'Medium', 290),
  ('interview', 'int-hr', 'HR Interview', 'Why should we hire you?', '[]'::jsonb, null, null, 'Medium', 291),
  ('interview', 'int-hr', 'HR Interview', 'Describe a conflict you resolved at work or college.', '[]'::jsonb, null, null, 'Medium', 292),
  ('interview', 'int-hr', 'HR Interview', 'Where do you see yourself in five years?', '[]'::jsonb, null, null, 'Medium', 293)
on conflict do nothing;

-- Coding problems: 36 rows
insert into coding_problems (category_id, title, difficulty, statement, input, output, examples, constraints, starter_code, solution, sort_order) values
  ('basics', 'Sum of Two Numbers', 'Easy', 'Given two integers a and b, return their sum.', 'Two integers a and b.', 'A single integer: a + b.', '[{"input": "3 5", "output": "8"}]'::jsonb, '-10^9 <= a, b <= 10^9', '{"Python": "def solve(a, b):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def solve(a, b):
    return a + b
', 1),
  ('basics', 'Check Prime Number', 'Medium', 'Given an integer n, return "Prime" if n is a prime number, otherwise return "Not Prime". Your solution should run in O(sqrt(n)).', 'A single integer n.', '"Prime" or "Not Prime".', '[{"input": "17", "output": "Prime"}, {"input": "15", "output": "Not Prime"}]'::jsonb, '1 <= n <= 10^9', '{"Python": "def is_prime(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def is_prime(n):
    if n < 2:
        return "Not Prime"
    i = 2
    while i * i <= n:
        if n % i == 0:
            return "Not Prime"
        i += 1
    return "Prime"
', 2),
  ('basics', 'Nth Fibonacci Number (Large N)', 'Hard', 'The Fibonacci sequence starts F(0) = 0, F(1) = 1 and F(n) = F(n-1) + F(n-2). Given n, return F(n) modulo 1,000,000,007. A linear loop is too slow for the largest n - use fast doubling or matrix exponentiation.', 'A single integer n.', 'F(n) modulo 1,000,000,007.', '[{"input": "10", "output": "55"}, {"input": "50", "output": "586268941"}]'::jsonb, '0 <= n <= 10^18', '{"Python": "def fib(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'MOD = 1_000_000_007

def fib(n):
    def fd(k):
        if k == 0:
            return (0, 1)
        a, b = fd(k >> 1)
        c = a * ((2 * b - a) % MOD) % MOD
        d = (a * a + b * b) % MOD
        return (d, (c + d) % MOD) if k & 1 else (c, d)
    return fd(n)[0]
', 3),
  ('arrays', 'Two Sum', 'Easy', 'Given an array of integers nums and an integer target, return the indices of the two numbers that add up to target. Exactly one solution exists and the same element cannot be used twice.', 'An array nums and an integer target.', 'The two indices [i, j] with i < j.', '[{"input": "nums = [2, 7, 11, 15], target = 9", "output": "[0, 1]"}]'::jsonb, '2 <= n <= 10^5, -10^9 <= nums[i], target <= 10^9', '{"Python": "def two_sum(nums, target):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def two_sum(nums, target):
    seen = {}
    for i, x in enumerate(nums):
        if target - x in seen:
            return [seen[target - x], i]
        seen[x] = i
    return []
', 1),
  ('arrays', 'Maximum Subarray Sum', 'Medium', 'Given an integer array nums, find the contiguous subarray with the largest sum and return that sum.', 'An integer array nums.', 'The maximum subarray sum.', '[{"input": "[-2, 1, -3, 4, -1, 2, 1, -5, 4]", "output": "6"}]'::jsonb, '1 <= n <= 10^5, -10^4 <= nums[i] <= 10^4', '{"Python": "def max_subarray(nums):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def max_subarray(nums):
    best = cur = nums[0]
    for x in nums[1:]:
        cur = max(x, cur + x)
        best = max(best, cur)
    return best
', 2),
  ('arrays', 'Trapping Rain Water', 'Hard', 'Given n non-negative integers representing an elevation map where each bar has width 1, compute how much water it can trap after raining.', 'An array height of non-negative integers.', 'The total units of trapped water.', '[{"input": "[0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]", "output": "6"}]'::jsonb, '1 <= n <= 2 * 10^4, 0 <= height[i] <= 10^5', '{"Python": "def trap(height):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def trap(height):
    left, right = 0, len(height) - 1
    left_max = right_max = water = 0
    while left < right:
        if height[left] < height[right]:
            left_max = max(left_max, height[left])
            water += left_max - height[left]
            left += 1
        else:
            right_max = max(right_max, height[right])
            water += right_max - height[right]
            right -= 1
    return water
', 3),
  ('strings', 'Reverse a String', 'Easy', 'Given a string s, return the string reversed.', 'A string s.', 'The reversed string.', '[{"input": "hello", "output": "olleh"}]'::jsonb, '1 <= |s| <= 10^5', '{"Python": "def reverse_string(s):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def reverse_string(s):
    return s[::-1]
', 1),
  ('strings', 'Longest Substring Without Repeating Characters', 'Medium', 'Given a string s, return the length of the longest substring that contains no repeated characters.', 'A string s.', 'The length of the longest such substring.', '[{"input": "abcabcbb", "output": "3"}]'::jsonb, '0 <= |s| <= 5 * 10^4', '{"Python": "def length_of_longest_substring(s):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def length_of_longest_substring(s):
    last = {}
    start = best = 0
    for i, ch in enumerate(s):
        if ch in last and last[ch] >= start:
            start = last[ch] + 1
        last[ch] = i
        best = max(best, i - start + 1)
    return best
', 2),
  ('strings', 'Minimum Window Substring', 'Hard', 'Given strings s and t, return the smallest substring of s that contains every character of t (including duplicates). Return an empty string if no such window exists.', 'Two strings s and t.', 'The minimum window substring, or an empty string.', '[{"input": "s = ADOBECODEBANC, t = ABC", "output": "BANC"}]'::jsonb, '1 <= |s|, |t| <= 10^5', '{"Python": "def min_window(s, t):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import Counter

def min_window(s, t):
    need = Counter(t)
    missing = len(t)
    best = (0, 0)
    left = 0
    for right, ch in enumerate(s, 1):
        if need[ch] > 0:
            missing -= 1
        need[ch] -= 1
        if missing == 0:
            while need[s[left]] < 0:
                need[s[left]] += 1
                left += 1
            if best == (0, 0) or right - left < best[1] - best[0]:
                best = (left, right)
            need[s[left]] += 1
            missing += 1
            left += 1
    return s[best[0]:best[1]]
', 3),
  ('searching', 'Binary Search', 'Easy', 'Given a sorted array of distinct integers nums and a target value, return the index of target, or -1 if it is not present. Your solution must run in O(log n).', 'A sorted array nums and an integer target.', 'The index of target or -1.', '[{"input": "nums = [-1, 0, 3, 5, 9, 12], target = 9", "output": "4"}]'::jsonb, '1 <= n <= 10^5', '{"Python": "def binary_search(nums, target):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def binary_search(nums, target):
    lo, hi = 0, len(nums) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1
', 1),
  ('searching', 'Search in Rotated Sorted Array', 'Medium', 'A sorted array of distinct integers was rotated at an unknown pivot (for example [0,1,2,4,5,6,7] became [4,5,6,7,0,1,2]). Given the rotated array and a target, return the index of target or -1. Aim for O(log n).', 'A rotated sorted array nums and an integer target.', 'The index of target or -1.', '[{"input": "nums = [4, 5, 6, 7, 0, 1, 2], target = 0", "output": "4"}]'::jsonb, '1 <= n <= 5000', '{"Python": "def search(nums, target):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def search(nums, target):
    lo, hi = 0, len(nums) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if nums[mid] == target:
            return mid
        if nums[lo] <= nums[mid]:
            if nums[lo] <= target < nums[mid]:
                hi = mid - 1
            else:
                lo = mid + 1
        else:
            if nums[mid] < target <= nums[hi]:
                lo = mid + 1
            else:
                hi = mid - 1
    return -1
', 2),
  ('searching', 'Split Array Largest Sum', 'Hard', 'Given an array of non-negative integers nums and an integer k, split the array into k non-empty contiguous subarrays so that the largest subarray sum is as small as possible. Return that minimised largest sum. Hint: binary search on the answer.', 'An array nums and an integer k.', 'The minimised largest subarray sum.', '[{"input": "nums = [7, 2, 5, 10, 8], k = 2", "output": "18"}]'::jsonb, '1 <= n <= 1000, 1 <= k <= n', '{"Python": "def split_array(nums, k):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def split_array(nums, k):
    lo, hi = max(nums), sum(nums)
    while lo < hi:
        mid = (lo + hi) // 2
        parts, cur = 1, 0
        for x in nums:
            if cur + x > mid:
                parts += 1
                cur = 0
            cur += x
        if parts <= k:
            hi = mid
        else:
            lo = mid + 1
    return lo
', 3),
  ('sorting', 'Sort an Array', 'Easy', 'Given an array of integers, return it sorted in ascending order. Implement a sorting algorithm yourself (bubble, insertion or merge sort) rather than using a built-in sort.', 'An integer array nums.', 'The array in ascending order.', '[{"input": "[5, 2, 3, 1]", "output": "[1, 2, 3, 5]"}]'::jsonb, '1 <= n <= 5 * 10^4', '{"Python": "def sort_array(nums):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def sort_array(nums):
    a = list(nums)
    for i in range(1, len(a)):
        key = a[i]
        j = i - 1
        while j >= 0 and a[j] > key:
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = key
    return a
', 1),
  ('sorting', 'Merge Intervals', 'Medium', 'Given a list of intervals [start, end], merge all overlapping intervals and return the non-overlapping intervals that cover the same ranges, sorted by start.', 'A list of intervals.', 'The merged intervals.', '[{"input": "[[1, 3], [2, 6], [8, 10], [15, 18]]", "output": "[[1, 6], [8, 10], [15, 18]]"}]'::jsonb, '1 <= n <= 10^4', '{"Python": "def merge(intervals):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def merge(intervals):
    result = []
    for start, end in sorted(intervals):
        if result and start <= result[-1][1]:
            result[-1][1] = max(result[-1][1], end)
        else:
            result.append([start, end])
    return result
', 2),
  ('sorting', 'Count Inversions', 'Hard', 'An inversion is a pair of indices i < j with nums[i] > nums[j]. Given an array, count its inversions in O(n log n) (hint: modify merge sort).', 'An integer array nums.', 'The number of inversions.', '[{"input": "[2, 4, 1, 3, 5]", "output": "3"}]'::jsonb, '1 <= n <= 10^5', '{"Python": "def count_inversions(nums):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def count_inversions(nums):
    def sort(a):
        if len(a) <= 1:
            return a, 0
        mid = len(a) // 2
        left, x = sort(a[:mid])
        right, y = sort(a[mid:])
        merged, i, j, cross = [], 0, 0, 0
        while i < len(left) and j < len(right):
            if left[i] <= right[j]:
                merged.append(left[i])
                i += 1
            else:
                merged.append(right[j])
                cross += len(left) - i
                j += 1
        merged += left[i:] + right[j:]
        return merged, x + y + cross
    return sort(list(nums))[1]
', 3),
  ('linkedlist', 'Reverse a Linked List', 'Easy', 'Given the head of a singly linked list, reverse the list and return the new head.', 'The values of the linked list, in order.', 'The values of the reversed list.', '[{"input": "1 -> 2 -> 3 -> 4 -> 5", "output": "5 -> 4 -> 3 -> 2 -> 1"}]'::jsonb, '0 <= n <= 5000', '{"Python": "class ListNode:\n    def __init__(self, val=0, next=None):\n        self.val = val\n        self.next = next\n\ndef reverse_list(head):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def reverse_list(head):
    prev = None
    while head:
        head.next, prev, head = prev, head, head.next
    return prev
', 1),
  ('linkedlist', 'Remove Nth Node From End', 'Medium', 'Given the head of a linked list and an integer n, remove the n-th node from the end of the list and return the head. Try to do it in one pass.', 'The linked list values and an integer n.', 'The values of the list after removal.', '[{"input": "1 -> 2 -> 3 -> 4 -> 5, n = 2", "output": "1 -> 2 -> 3 -> 5"}]'::jsonb, '1 <= size <= 30, 1 <= n <= size', '{"Python": "class ListNode:\n    def __init__(self, val=0, next=None):\n        self.val = val\n        self.next = next\n\ndef remove_nth_from_end(head, n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def remove_nth_from_end(head, n):
    dummy = ListNode(0, head)
    fast = slow = dummy
    for _ in range(n):
        fast = fast.next
    while fast.next:
        fast, slow = fast.next, slow.next
    slow.next = slow.next.next
    return dummy.next
', 2),
  ('linkedlist', 'Merge K Sorted Lists', 'Hard', 'You are given k sorted linked lists. Merge them into one sorted linked list and return its head.', 'k sorted linked lists.', 'The values of the merged sorted list.', '[{"input": "[1 -> 4 -> 5], [1 -> 3 -> 4], [2 -> 6]", "output": "1 -> 1 -> 2 -> 3 -> 4 -> 4 -> 5 -> 6"}]'::jsonb, '0 <= k <= 10^4, total nodes <= 10^4', '{"Python": "class ListNode:\n    def __init__(self, val=0, next=None):\n        self.val = val\n        self.next = next\n\ndef merge_k_lists(lists):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'import heapq

def merge_k_lists(lists):
    heap = [(node.val, i, node) for i, node in enumerate(lists) if node]
    heapq.heapify(heap)
    dummy = tail = ListNode()
    while heap:
        _, i, node = heapq.heappop(heap)
        tail.next = node
        tail = node
        if node.next:
            heapq.heappush(heap, (node.next.val, i, node.next))
    return dummy.next
', 3),
  ('stack', 'Valid Parentheses', 'Easy', 'Given a string containing only the characters ( ) { } [ ], determine whether the brackets are valid: every opening bracket is closed by the same type, in the correct order.', 'A string s of brackets.', 'true or false.', '[{"input": "()[]{}", "output": "true"}, {"input": "(]", "output": "false"}]'::jsonb, '1 <= |s| <= 10^4', '{"Python": "def is_valid(s):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def is_valid(s):
    pairs = {'')'': ''('', '']'': ''['', ''}'': ''{''}
    stack = []
    for ch in s:
        if ch in pairs:
            if not stack or stack.pop() != pairs[ch]:
                return False
        else:
            stack.append(ch)
    return not stack
', 1),
  ('stack', 'Next Greater Element', 'Medium', 'For each element of an array, find the first greater element to its right. If none exists use -1. Return the results as an array.', 'An integer array nums.', 'An array of next greater elements.', '[{"input": "[4, 5, 2, 25]", "output": "[5, 25, 25, -1]"}]'::jsonb, '1 <= n <= 10^5', '{"Python": "def next_greater(nums):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def next_greater(nums):
    result = [-1] * len(nums)
    stack = []
    for i, x in enumerate(nums):
        while stack and nums[stack[-1]] < x:
            result[stack.pop()] = x
        stack.append(i)
    return result
', 2),
  ('stack', 'Largest Rectangle in Histogram', 'Hard', 'Given an array of bar heights of a histogram where each bar has width 1, return the area of the largest rectangle that fits inside the histogram.', 'An array heights.', 'The largest rectangle area.', '[{"input": "[2, 1, 5, 6, 2, 3]", "output": "10"}]'::jsonb, '1 <= n <= 10^5, 0 <= heights[i] <= 10^4', '{"Python": "def largest_rectangle(heights):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def largest_rectangle(heights):
    stack, best = [], 0
    for i, h in enumerate(heights + [0]):
        start = i
        while stack and stack[-1][1] >= h:
            idx, height = stack.pop()
            best = max(best, height * (i - idx))
            start = idx
        stack.append((start, h))
    return best
', 3),
  ('queue', 'Reverse First K Elements of a Queue', 'Easy', 'Given a queue of integers and an integer k, reverse the order of the first k elements while keeping the remaining elements in their original order. Return the resulting queue as a list.', 'A queue (list) and an integer k.', 'The modified queue.', '[{"input": "queue = [1, 2, 3, 4, 5], k = 3", "output": "[3, 2, 1, 4, 5]"}]'::jsonb, '1 <= k <= n <= 10^5', '{"Python": "def reverse_first_k(queue, k):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import deque

def reverse_first_k(queue, k):
    q = deque(queue)
    stack = [q.popleft() for _ in range(k)]
    while stack:
        q.append(stack.pop())
    for _ in range(len(q) - k):
        q.append(q.popleft())
    return list(q)
', 1),
  ('queue', 'Generate Binary Numbers from 1 to N', 'Medium', 'Given an integer n, generate the binary representations of the numbers 1 to n using a queue (no built-in binary conversion).', 'A single integer n.', 'A list of n binary strings.', '[{"input": "5", "output": "[\"1\", \"10\", \"11\", \"100\", \"101\"]"}]'::jsonb, '1 <= n <= 10^5', '{"Python": "def generate_binary(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import deque

def generate_binary(n):
    result, q = [], deque(["1"])
    for _ in range(n):
        cur = q.popleft()
        result.append(cur)
        q.append(cur + "0")
        q.append(cur + "1")
    return result
', 2),
  ('queue', 'Sliding Window Maximum', 'Hard', 'Given an array nums and a window size k that slides from the far left to the far right one position at a time, return the maximum of each window. Aim for O(n) using a deque.', 'An array nums and an integer k.', 'An array with the maximum of each window.', '[{"input": "nums = [1, 3, -1, -3, 5, 3, 6, 7], k = 3", "output": "[3, 3, 5, 5, 6, 7]"}]'::jsonb, '1 <= k <= n <= 10^5', '{"Python": "def max_sliding_window(nums, k):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import deque

def max_sliding_window(nums, k):
    dq, result = deque(), []
    for i, x in enumerate(nums):
        while dq and nums[dq[-1]] <= x:
            dq.pop()
        dq.append(i)
        if dq[0] <= i - k:
            dq.popleft()
        if i >= k - 1:
            result.append(nums[dq[0]])
    return result
', 3),
  ('trees', 'Maximum Depth of Binary Tree', 'Easy', 'Given the root of a binary tree, return its maximum depth - the number of nodes on the longest path from the root down to a leaf.', 'A binary tree in level order (null for missing nodes).', 'The maximum depth.', '[{"input": "[3, 9, 20, null, null, 15, 7]", "output": "3"}]'::jsonb, '0 <= n <= 10^4', '{"Python": "class TreeNode:\n    def __init__(self, val=0, left=None, right=None):\n        self.val = val\n        self.left = left\n        self.right = right\n\ndef max_depth(root):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def max_depth(root):
    if not root:
        return 0
    return 1 + max(max_depth(root.left), max_depth(root.right))
', 1),
  ('trees', 'Binary Tree Level Order Traversal', 'Medium', 'Given the root of a binary tree, return the values of its nodes level by level, from left to right.', 'A binary tree in level order (null for missing nodes).', 'A list of levels.', '[{"input": "[3, 9, 20, null, null, 15, 7]", "output": "[[3], [9, 20], [15, 7]]"}]'::jsonb, '0 <= n <= 2000', '{"Python": "class TreeNode:\n    def __init__(self, val=0, left=None, right=None):\n        self.val = val\n        self.left = left\n        self.right = right\n\ndef level_order(root):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import deque

def level_order(root):
    if not root:
        return []
    result, q = [], deque([root])
    while q:
        level = []
        for _ in range(len(q)):
            node = q.popleft()
            level.append(node.val)
            if node.left:
                q.append(node.left)
            if node.right:
                q.append(node.right)
        result.append(level)
    return result
', 2),
  ('trees', 'Binary Tree Maximum Path Sum', 'Hard', 'A path in a binary tree is any sequence of connected nodes (it need not pass through the root). Return the maximum sum of node values over all non-empty paths.', 'A binary tree in level order (null for missing nodes).', 'The maximum path sum.', '[{"input": "[-10, 9, 20, null, null, 15, 7]", "output": "42"}]'::jsonb, '1 <= n <= 3 * 10^4, -1000 <= val <= 1000', '{"Python": "class TreeNode:\n    def __init__(self, val=0, left=None, right=None):\n        self.val = val\n        self.left = left\n        self.right = right\n\ndef max_path_sum(root):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def max_path_sum(root):
    best = [float(''-inf'')]
    def gain(node):
        if not node:
            return 0
        left = max(gain(node.left), 0)
        right = max(gain(node.right), 0)
        best[0] = max(best[0], node.val + left + right)
        return node.val + max(left, right)
    gain(root)
    return best[0]
', 3),
  ('graphs', 'Find if Path Exists in Graph', 'Easy', 'There is a bi-directional graph with n vertices labelled 0 to n-1 and a list of edges. Return true if there is a path from source to destination.', 'n, a list of edges, source and destination.', 'true or false.', '[{"input": "n = 3, edges = [[0,1],[1,2],[2,0]], source = 0, destination = 2", "output": "true"}]'::jsonb, '1 <= n <= 2 * 10^5', '{"Python": "def valid_path(n, edges, source, destination):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'from collections import defaultdict, deque

def valid_path(n, edges, source, destination):
    graph = defaultdict(list)
    for u, v in edges:
        graph[u].append(v)
        graph[v].append(u)
    seen, q = {source}, deque([source])
    while q:
        node = q.popleft()
        if node == destination:
            return True
        for nxt in graph[node]:
            if nxt not in seen:
                seen.add(nxt)
                q.append(nxt)
    return False
', 1),
  ('graphs', 'Number of Islands', 'Medium', 'Given a 2D grid of "1" (land) and "0" (water), count the islands. An island is formed by connecting adjacent land cells horizontally or vertically.', 'A grid of "1" and "0" characters.', 'The number of islands.', '[{"input": "[[1,1,0,0,0],[1,1,0,0,0],[0,0,1,0,0],[0,0,0,1,1]]", "output": "3"}]'::jsonb, '1 <= rows, cols <= 300', '{"Python": "def num_islands(grid):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def num_islands(grid):
    rows, cols = len(grid), len(grid[0])
    seen = set()
    def dfs(r, c):
        stack = [(r, c)]
        while stack:
            x, y = stack.pop()
            if not (0 <= x < rows and 0 <= y < cols) or (x, y) in seen or grid[x][y] != ''1'':
                continue
            seen.add((x, y))
            stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    count = 0
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == ''1'' and (r, c) not in seen:
                count += 1
                dfs(r, c)
    return count
', 2),
  ('graphs', 'Shortest Path in Weighted Graph (Dijkstra)', 'Hard', 'Given a directed graph with n vertices (0 to n-1) and weighted edges [u, v, w] with non-negative weights, return the shortest distance from the source vertex to every vertex (use -1 for unreachable vertices).', 'n, a list of weighted edges [u, v, w] and a source vertex.', 'A list of n shortest distances.', '[{"input": "n = 5, edges = [[0,1,4],[0,2,1],[2,1,2],[1,3,1],[2,3,5],[3,4,3]], source = 0", "output": "[0, 3, 1, 4, 7]"}]'::jsonb, '1 <= n <= 10^4, 0 <= w <= 10^6', '{"Python": "def dijkstra(n, edges, source):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'import heapq

def dijkstra(n, edges, source):
    graph = [[] for _ in range(n)]
    for u, v, w in edges:
        graph[u].append((v, w))
    dist = [float(''inf'')] * n
    dist[source] = 0
    heap = [(0, source)]
    while heap:
        d, u = heapq.heappop(heap)
        if d > dist[u]:
            continue
        for v, w in graph[u]:
            if d + w < dist[v]:
                dist[v] = d + w
                heapq.heappush(heap, (dist[v], v))
    return [d if d != float(''inf'') else -1 for d in dist]
', 3),
  ('recursion', 'Factorial', 'Easy', 'Given a non-negative integer n, return n! (the product of all integers from 1 to n) using recursion. 0! is 1.', 'A single integer n.', 'n!', '[{"input": "5", "output": "120"}]'::jsonb, '0 <= n <= 20', '{"Python": "def factorial(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def factorial(n):
    return 1 if n <= 1 else n * factorial(n - 1)
', 1),
  ('recursion', 'Generate All Subsets', 'Medium', 'Given an array of distinct integers, return all possible subsets (the power set) in any order.', 'An array nums of distinct integers.', 'A list of all subsets.', '[{"input": "[1, 2, 3]", "output": "[[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]"}]'::jsonb, '1 <= n <= 10', '{"Python": "def subsets(nums):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def subsets(nums):
    result = []
    def build(i, cur):
        if i == len(nums):
            result.append(cur[:])
            return
        build(i + 1, cur)
        cur.append(nums[i])
        build(i + 1, cur)
        cur.pop()
    build(0, [])
    return result
', 2),
  ('recursion', 'N-Queens (Count Solutions)', 'Hard', 'Place n queens on an n x n chessboard so that no two queens attack each other (same row, column or diagonal). Return the number of distinct solutions.', 'A single integer n.', 'The number of distinct solutions.', '[{"input": "4", "output": "2"}]'::jsonb, '1 <= n <= 9', '{"Python": "def total_n_queens(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def total_n_queens(n):
    cols, d1, d2 = set(), set(), set()
    def place(r):
        if r == n:
            return 1
        total = 0
        for c in range(n):
            if c in cols or r - c in d1 or r + c in d2:
                continue
            cols.add(c); d1.add(r - c); d2.add(r + c)
            total += place(r + 1)
            cols.remove(c); d1.remove(r - c); d2.remove(r + c)
        return total
    return place(0)
', 3),
  ('dp', 'Climbing Stairs', 'Easy', 'You are climbing a staircase with n steps. Each time you can climb 1 or 2 steps. In how many distinct ways can you reach the top?', 'A single integer n.', 'The number of distinct ways.', '[{"input": "5", "output": "8"}]'::jsonb, '1 <= n <= 45', '{"Python": "def climb_stairs(n):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def climb_stairs(n):
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b
', 1),
  ('dp', '0/1 Knapsack', 'Medium', 'Given weights and values of n items and a knapsack capacity, find the maximum total value you can carry. Each item can be taken at most once.', 'Arrays weights and values, and an integer capacity.', 'The maximum total value.', '[{"input": "weights = [1, 3, 4, 5], values = [1, 4, 5, 7], capacity = 7", "output": "9"}]'::jsonb, '1 <= n <= 100, 1 <= capacity <= 10^4', '{"Python": "def knapsack(weights, values, capacity):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def knapsack(weights, values, capacity):
    dp = [0] * (capacity + 1)
    for w, v in zip(weights, values):
        for c in range(capacity, w - 1, -1):
            dp[c] = max(dp[c], dp[c - w] + v)
    return dp[capacity]
', 2),
  ('dp', 'Edit Distance', 'Hard', 'Given two strings word1 and word2, return the minimum number of operations (insert, delete or replace a character) needed to convert word1 into word2.', 'Two strings word1 and word2.', 'The minimum number of operations.', '[{"input": "word1 = horse, word2 = ros", "output": "3"}]'::jsonb, '0 <= |word1|, |word2| <= 500', '{"Python": "def min_distance(word1, word2):\n    # TODO: write your solution\n    pass\n"}'::jsonb, 'def min_distance(word1, word2):
    m, n = len(word1), len(word2)
    prev = list(range(n + 1))
    for i in range(1, m + 1):
        cur = [i] + [0] * n
        for j in range(1, n + 1):
            if word1[i - 1] == word2[j - 1]:
                cur[j] = prev[j - 1]
            else:
                cur[j] = 1 + min(prev[j], cur[j - 1], prev[j - 1])
        prev = cur
    return prev[n]
', 3)
on conflict (category_id, title) do update set difficulty = excluded.difficulty, statement = excluded.statement, input = excluded.input,
  output = excluded.output, examples = excluded.examples, constraints = excluded.constraints, starter_code = excluded.starter_code,
  solution = excluded.solution, sort_order = excluded.sort_order;

-- Companies
insert into companies (id, name, color, overview, eligibility, process, focus_topics, sections, sort_order) values
  ('tcs', 'TCS', 'bg-indigo-600', 'TCS (Tata Consultancy Services) is a large Indian IT services and consulting company that regularly hires freshers through campus drives.', '60% and above in 10th, 12th and Degree, no active backlogs.', '["Aptitude", "Technical", "Coding", "HR"]'::jsonb, '{"aptitude": ["Number System", "Percentage", "Profit & Loss", "Time & Work", "Number Series", "Coding & Decoding"], "technical": ["C", "Java", "DBMS", "Data Structures"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Number System, Percentage, Profit & Loss, Time & Work, Number Series, Coding & Decoding.", "Technical Questions": "Focus topics: C, Java, DBMS, Data Structures.", "Coding Questions": "Practice categories: Basic Programming, Arrays, Strings.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 1),
  ('infosys', 'Infosys', 'bg-blue-600', 'Infosys is a global IT services and consulting company headquartered in India that hires freshers in large numbers every year.', '65% throughout academics, consistent performance preferred.', '["Aptitude", "Technical", "Coding", "HR"]'::jsonb, '{"aptitude": ["Percentage", "Ratio & Proportion", "Number Series", "Syllogisms", "Synonyms", "Sentence Correction"], "technical": ["Python", "OOP", "DBMS", "SQL"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Percentage, Ratio & Proportion, Number Series, Syllogisms, Synonyms, Sentence Correction.", "Technical Questions": "Focus topics: Python, OOP, DBMS, SQL.", "Coding Questions": "Practice categories: Arrays, Strings, Sorting.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 2),
  ('accenture', 'Accenture', 'bg-violet-600', 'Accenture is a global professional services company offering technology, consulting and operations services.', '60% aggregate, all branches eligible.', '["Aptitude", "Technical", "HR"]'::jsonb, '{"aptitude": ["Percentage", "Time, Speed & Distance", "Blood Relations", "Error Spotting", "Reading Comprehension"], "technical": ["Computer Networks", "Operating Systems", "Cloud Basics", "Cyber Security Basics"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Percentage, Time, Speed & Distance, Blood Relations, Error Spotting, Reading Comprehension.", "Technical Questions": "Focus topics: Computer Networks, Operating Systems, Cloud Basics, Cyber Security Basics.", "Coding Questions": "Practice categories: Basic Programming.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 3),
  ('wipro', 'Wipro', 'bg-indigo-500', 'Wipro is an Indian multinational technology services and consulting company with a regular campus hiring programme.', '60% aggregate, no standing arrears.', '["Aptitude", "Coding", "Technical", "HR"]'::jsonb, '{"aptitude": ["Simple Interest", "Average", "Direction Sense", "Antonyms", "Sentence Completion"], "technical": ["Java", "Data Structures", "SQL"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Simple Interest, Average, Direction Sense, Antonyms, Sentence Completion.", "Technical Questions": "Focus topics: Java, Data Structures, SQL.", "Coding Questions": "Practice categories: Arrays, Strings, Sorting.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 4),
  ('cognizant', 'Cognizant', 'bg-sky-600', 'Cognizant is a global IT services and consulting company that recruits freshers across engineering branches.', '60% aggregate, B.E/B.Tech/M.E/M.Tech.', '["Aptitude", "Coding", "HR"]'::jsonb, '{"aptitude": ["Percentage", "Time & Work", "Analogy", "Para Jumbles", "Fill in the Blanks"], "technical": ["Python", "SQL", "OOP"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Percentage, Time & Work, Analogy, Para Jumbles, Fill in the Blanks.", "Technical Questions": "Focus topics: Python, SQL, OOP.", "Coding Questions": "Practice categories: Basic Programming, Arrays, Strings.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 5),
  ('zoho', 'Zoho', 'bg-red-500', 'Zoho is a product-based software company known for putting strong emphasis on problem solving and programming ability in its hiring.', 'Open to all percentages, strong coding round emphasis.', '["Coding", "Technical", "HR"]'::jsonb, '{"aptitude": ["Number Series", "Puzzles", "Permutation & Combination"], "technical": ["C", "C++", "Data Structures", "Algorithms"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Number Series, Puzzles, Permutation & Combination.", "Technical Questions": "Focus topics: C, C++, Data Structures, Algorithms.", "Coding Questions": "Practice categories: Arrays, Strings, Recursion, Dynamic Programming.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 6),
  ('capgemini', 'Capgemini', 'bg-blue-500', 'Capgemini is a global consulting, technology and digital transformation company that hires freshers through campus drives.', '60% aggregate, pseudo-code test included.', '["Aptitude", "Coding", "Technical", "HR"]'::jsonb, '{"aptitude": ["Percentage", "Profit & Loss", "Letter Series", "Synonyms", "Error Spotting"], "technical": ["C", "Java", "Software Engineering", "DBMS"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Percentage, Profit & Loss, Letter Series, Synonyms, Error Spotting.", "Technical Questions": "Focus topics: C, Java, Software Engineering, DBMS.", "Coding Questions": "Practice categories: Basic Programming, Arrays.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 7),
  ('hcl', 'HCL', 'bg-purple-600', 'HCLTech is an Indian multinational IT services and consulting company with regular fresher recruitment.', '60% aggregate, TalentQ assessment.', '["Aptitude", "Technical", "HR"]'::jsonb, '{"aptitude": ["Number System", "Ratio & Proportion", "Coding & Decoding", "Vocabulary"], "technical": ["C++", "Computer Networks", "Operating Systems"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Number System, Ratio & Proportion, Coding & Decoding, Vocabulary.", "Technical Questions": "Focus topics: C++, Computer Networks, Operating Systems.", "Coding Questions": "Practice categories: Basic Programming.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 8),
  ('deloitte', 'Deloitte', 'bg-emerald-600', 'Deloitte is a global professional services network offering audit, consulting, tax and technology services.', '65% aggregate, strong communication emphasis.', '["Aptitude", "Technical", "HR"]'::jsonb, '{"aptitude": ["Tables", "Bar Graphs", "Pie Charts", "Reading Comprehension", "Sentence Correction"], "technical": ["SQL", "Database Design", "Cyber Security Basics"]}'::jsonb, '{"Aptitude Preparation": "Focus topics: Tables, Bar Graphs, Pie Charts, Reading Comprehension, Sentence Correction.", "Technical Questions": "Focus topics: SQL, Database Design, Cyber Security Basics.", "Coding Questions": "No dedicated coding round is listed for this practice track; basic programming practice still helps.", "HR Questions": "Common HR, behavioral and situational questions are available under HR Interview.", "Previous Mock Tests": "Use Start Company Mock for a test built from this company''s focus topics above.", "Interview Tips": "Research the company and role beforehand; Answer with the STAR method (Situation, Task, Action, Result); Be honest, concise and specific."}'::jsonb, 9)
on conflict (id) do update set name = excluded.name, color = excluded.color, overview = excluded.overview, eligibility = excluded.eligibility,
  process = excluded.process, focus_topics = excluded.focus_topics, sections = excluded.sections, sort_order = excluded.sort_order;

-- Presentation topics
insert into presentation_topics (title, description, prep_seconds, speak_seconds, tips, sort_order) values
  ('Technical Presentation', 'Explain a technical concept clearly to a mixed audience.', 60, 120, '["Start with the problem the concept solves", "Use one simple example or analogy", "Close with a one-line takeaway"]'::jsonb, 1),
  ('Project Presentation', 'Present a project you built: problem, approach, result.', 60, 120, '["State the problem and who it helps", "Describe your role and the tech stack", "Share one result or lesson learned"]'::jsonb, 2),
  ('Seminar', 'Deliver a short seminar-style talk on a topic you know well.', 60, 120, '["Open with a hook or question", "Keep to two or three main points", "Summarise and invite questions"]'::jsonb, 3),
  ('Self Introduction', 'Introduce yourself the way you would in an interview.', 30, 60, '["Name, education and key skills", "One project or achievement", "What you are looking for next"]'::jsonb, 4),
  ('Elevator Pitch', 'Pitch yourself or an idea in about a minute.', 30, 60, '["Lead with the most important point", "Be specific, avoid filler", "End with a clear ask"]'::jsonb, 5),
  ('Product Presentation', 'Present a product: who it is for and why it is useful.', 60, 120, '["Define the target user and their pain", "Show two or three key features", "Explain why it beats the alternatives"]'::jsonb, 6)
on conflict (title) do update set description = excluded.description, prep_seconds = excluded.prep_seconds,
  speak_seconds = excluded.speak_seconds, tips = excluded.tips, sort_order = excluded.sort_order;

-- GD categories and topics
insert into gd_categories (id, name, sort_order) values
  ('current', 'Current Topics', 1),
  ('tech', 'Technology', 2),
  ('business', 'Business', 3),
  ('social', 'Social Topics', 4),
  ('abstract', 'Abstract Topics', 5),
  ('campus', 'Campus Placement Topics', 6)
on conflict (id) do update set name = excluded.name, sort_order = excluded.sort_order;

insert into gd_topics (category_id, topic, sort_order) values
  ('current', 'Impact of AI on jobs', 1),
  ('current', 'India''s semiconductor push', 2),
  ('current', 'Remote work vs office culture', 3),
  ('tech', 'Is social media doing more harm than good?', 1),
  ('tech', 'Should coding be taught from school?', 2),
  ('tech', 'Future of electric vehicles', 3),
  ('business', 'Startups vs stable jobs', 1),
  ('business', 'Impact of e-commerce on local retail', 2),
  ('business', 'Work-life balance in corporates', 3),
  ('social', 'Reservation system in India', 1),
  ('social', 'Online education vs traditional education', 2),
  ('social', 'Should exams be abolished?', 3),
  ('abstract', 'Colour', 1),
  ('abstract', 'Silence', 2),
  ('abstract', 'The number Zero', 3),
  ('campus', 'Is CGPA a fair measure of talent?', 1),
  ('campus', 'Should placements be the sole focus of college?', 2),
  ('campus', 'Internships vs academics', 3)
on conflict (category_id, topic) do update set sort_order = excluded.sort_order;
