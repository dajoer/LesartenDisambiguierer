#!/usr/bin/env ruby
require 'sqlite3'

def checkFile(file)
	if not test("f", file) then
		puts "File #{file} not found."
		exit
	end
end

def lemmatize(w)
	return w
end

def maxId(inthash)
	maxV = 0
	for i, v in inthash
		if v >= maxV then
			maxI = i
		end
	end
	return maxI
end

def disambiguiere(word, context, db)
	id = db.execute("SELECT id FROM woerter WHERE lemma == '#{word}' LIMIT 1")[0]
	if id != nil then
		bedeutungen = db.execute("SELECT * FROM bedeutung WHERE wortid == #{id[0]}")
		score = {}
		bedeutungen.each_with_index do |line, i|
			context.each do |w|
				if eval(line[3]).include?(w) then
					if score[i] == nil then
						score[i] = 1
					else
						score[i] += 1
					end
				end
			end
		end
		puts "#{word}: #{bedeutungen[maxId(score)][2]}"
	else
		puts "#{word}: keine Ambiguität"
	end
end

#Prüfen ob notwendige Dateien vorhanden sind
if ARGV.length < 2 then
	puts "Usage: disambig.rb <stopwordFile> <textFile>"
	exit
end
checkFile(ARGV[0])
checkFile(ARGV[1])

#Stoppwörter einlesen
fileReader = open(ARGV[0], "r")
stopWords = fileReader.read.split
fileReader.close

#Text einlesen
fileReader = open(ARGV[1], "r")
text = fileReader.read.split
fileReader.close

words = []
text.each do |w|
	if not stopWords.include?(w)
		words << lemmatize(w)
	end
end

woerterbuch = SQLite3::Database.open("woerterbuch.sqlite")
#disambiguiere("Bank", ["sitze", "Park", "Zeitung"], woerterbuch)
#disambiguiere("Käse", ["sitze", "Park"], woerterbuch)
#words.each do |w|
#	disambiguiere(w, words, woerterbuch)
#end

for i in (0...words.length) do
	start = (i>5 ? i-5 : 0)
	ende  = (i+5 > words.length ? words.length : i+5)
	disambiguiere(words[i], words[start,ende], woerterbuch)
end
