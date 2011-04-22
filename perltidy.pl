system 'perltidy --pro=perltidyrc ' . $_ for glob './lib/*.pm';
system 'perltidy --pro=perltidyrc ' . $_ for glob './lib/Scrappy/*.pm';
system 'perltidy --pro=perltidyrc ' . $_ for glob './lib/Scrappy/Plugin/*.pm';
system 'perltidy --pro=perltidyrc ' . $_ for glob './lib/Scrappy/Scraper/*.pm';

print  'tidy complete';