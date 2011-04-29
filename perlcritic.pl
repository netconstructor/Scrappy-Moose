system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/*.pm";
system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/Scrappy/*.pm";
system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/Scrappy/Action/*.pm";
system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/Scrappy/Plugin/*.pm";
system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/Scrappy/Project/*.pm";
system "perlcritic --profile=perlcriticrc " . $_ for glob "./lib/Scrappy/Scraper/*.pm";