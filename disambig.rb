#!/usr/bin/env ruby
require 'sqlite3'

def readFile(file)
	if not test("f", file) then
		puts "File #{file} not found."
		exit
	end
	fileReader = open(file, "r")
	text = fileReader.read.split
	fileReader.close
	return text
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

def disambiguiereText(words, context, woerterbuch)
	for i in (0...words.length) do
		c = (context/2).to_i
		start = (i>c ? i-c : 0)
		disambiguiere(words[i], words[start,context+1], woerterbuch)
	end
end

#Prüfen ob notwendige Dateien vorhanden sind
#und Stoppwörter und Text einlesen
if ARGV.length < 2 then
	puts "Usage: disambig.rb <stopwordFile> <textFile>"
	exit
end
stopWords = readFile(ARGV[0])
text = readFile(ARGV[1])

#Stoppwörter entfernen und Text Lemmatisieren
words = []
text.each do |w|
	if not stopWords.include?(w)
		words << lemmatize(w)
	end
end

woerterB = SQLite3::Database.open("woerterbuch.sqlite")

disambiguiereText(words, 4, woerterB)
