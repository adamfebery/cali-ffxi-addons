--[[ From SheolHelper by Marian Arlt (https://github.com/MarianArlt/sheolhelper)
BSD 3-Clause License

Copyright (c) 2022, Marian Arlt
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--[[
    First value represents an additional resistance bonus supposedly given to mobs of that type inside Odyssey.
    Said bonus is strictly made up from observations made by the user base and has not been confirmed by SquareEnix
    as of the writing of this addon.
--]]

return {
    -- Nostos mobs and NMs
    ['Amorph']   = {'Magic',    'Allergorhai','Bes','Black Pudding','Clot','Flan','Gloios','Hecteyes','Leech','Slime','Worm'},
    ['Aquan']    = {'Slashing', 'Brachys','Crab','Fish','Jagil','Kraken','Nerites','Pugil','Taniwha','Uragnite'},
    ['Arcana']   = {'Piercing', 'Bendigeidfran','Bomb','Bygul','Cluster','Evil Weapon','Fornax','Giant','Harpe','Ishum','Magic Pot','Mimic','Shara','Weapon'},
    ['Beast']    = {'Piercing', 'Ailuros','Asena','Buffalo','Bugard','Chnubis','Coeurl','Dabbat al-Ard','Dhalmel','Karakul','Kusarikku','Leopard','Manticore','Marid','Opo-opo','Ptesan Wi','Ram','Rarab','Sheep','Tiger'},
    ['Bird']     = {'Blunt',    'Aegypius','Apkallu','Bat','Bats','Bigbird','Colibri','Cockatrice','Gandji','Langmeidong','Leucippe','Megaera','Roc','Simir','Vulture','Zacatzontli','Ziz'},
    ['Demon']    = {'Piercing', 'Ahriman','Chaos Steward','Imp','Soulflayer','Taurus'},
    ['Dragon']   = {'Blunt',    'Azdaha','Dahak','Drake','Kuk','Lotanu','Puk','Wayra Tata','Wyvern'},
    ['Lizard']   = {'Blunt',    'Eft','Kurmajara','Lizard','Raptor','Salmandra'},
    ['Plantoid'] = {'Magic',    'Ameretat','Cynara','Damysus','Dione','Eurytus','Flytrap','Funguar','Goobbue','Korrigan','Mandragora','Maverick Maude','Morbol','Physis','Ptelea','Sabotender','Sapling','Treant'},
    ['Undead']   = {'Slashing', 'Bhoot','Corse','Count Malefis','Doom Toad','Draugar','Ghost','Ghoul','Gravehaunter','Hound','Qutrub','Skeleton','Spyrysyon'},
    ['Vermin']   = {'Magic',    'Akidu','Beetle','Chelamma','Chigoe','Crawler','Damselfly','Defoliator','Diremite','Eruca','Fly','Gaganbo','Man-kheper-re','Scorpion','Spider','Spinner','Tabitjet','Tipuli','Wamoura','Wamouracampa','Wasp'},
    ['Goblin']   = {'Unknown',  'Tripix'},
    -- Agon beastmen and a few NMs (cleric appears twice, for the sake of simplicity resistances.lua will refer to the Mamool cleric)
    -- TODO: Testing needed in Sheol A for the respective agon beastmen weapon resistances, also Tripix
    ['Orc']      = {'Unknown',  'Archer','Black Belt','Crusader','Fighter','Pugilist','Renegade','Thaumaturge','Villifier'},
    ['Yagudo']   = {'Unknown',  'Archon','Bruiser','Chirurgeon','Lyricist','Magus','Samurai','Shinobi','Spiritualist'},
    ['Quadav']   = {'Unknown',  'Champion','Cleric','Enchanter','Evoker','Marauder','Pillager','Ravager','Squire'},
    ['Antica']   = {'Blunt',    'Apollinaris VII-II','Cleaver','Culler','Errant','Magister','Man-at-Arms','Soldier','Swiftcaster','Warden'},
    ['Sahagin']  = {'Piercing', 'Chemister','Dragonmaster','Healer','Lancer','Mendicant','Muse','Stoicist','Tamer'},
    ['Tonberry'] = {'Slashing', 'Agent','Assassin','Channeler','Fleet-footed Lokberry','Hexer','Kunoichi','Pickpocket','Rogue','Spy'},
    ['Mamool']   = {'Piercing', 'Cleric','Heretic','Initiate','Instigator','Marquess','Phalanx','Pilferer','Praetor'},
    ['Troll']    = {'Blunt',    'Clearmind','Defender','Footsoldier','Infidel','Ritualist','Sharpshooter','Shieldsaint','Viscount'},
    ['Lamia']    = {'Slashing', 'Adjudicator','Dignitary','Marksman','Monarch','Rabblerouser','Scallywag','Vizier','Yojimbo'},
}