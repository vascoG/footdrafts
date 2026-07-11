defmodule FootDrafts.Football.ImportPayloads.Epl do
  @moduledoc false

  @spec payload() :: map()
  def payload do
    %{
      competition: %{
        name: "Premier League",
        country: "England",
        tier: 1,
        external_id: "EPL"
      },
      clubs: [
        %{
          name: "Manchester City",
          country: "England",
          external_id: "EPL-MCI",
          players: [
            player("Erling Haaland", "Forward", "Norway", "EPL-MCI-HAALAND", 93),
            player("Rodri", "Midfielder", "Spain", "EPL-MCI-RODRI", 92),
            player("Phil Foden", "Midfielder", "England", "EPL-MCI-FODEN", 90),
            player("Ruben Dias", "Defender", "Portugal", "EPL-MCI-DIAS", 89),
            player("Josko Gvardiol", "Defender", "Croatia", "EPL-MCI-GVARDIOL", 88),
            player("Jeremy Doku", "Forward", "Belgium", "EPL-MCI-DOKU", 85),
            player("Savinho", "Forward", "Brazil", "EPL-MCI-SAVINHO", 85),
            player("Mateo Kovacic", "Midfielder", "Croatia", "EPL-MCI-KOVACIC", 83),
            player("Rico Lewis", "Defender", "England", "EPL-MCI-RLEWIS", 84),
            player("Elliot Anderson", "Midfielder", "Scotland", "EPL-MCI-ANDERSON", 83),
            player("Jack Grealish", "Forward", "England", "EPL-MCI-GREALISH", 82),
            player("Stefan Ortega", "Goalkeeper", "Germany", "EPL-MCI-ORTEGA", 81)
          ]
        },
        %{
          name: "Liverpool",
          country: "England",
          external_id: "EPL-LIV",
          players: [
            player("Virgil van Dijk", "Defender", "Netherlands", "EPL-LIV-VVD", 89),
            player("Alisson", "Goalkeeper", "Brazil", "EPL-LIV-ALISSON", 88),
            player("Alexis Mac Allister", "Midfielder", "Argentina", "EPL-LIV-MACALLISTER", 88),
            player("Luis Diaz", "Forward", "Colombia", "EPL-LIV-LDIAZ", 87),
            player("Ryan Gravenberch", "Midfielder", "Netherlands", "EPL-LIV-GRAVENBERCH", 86),
            player("Dominik Szoboszlai", "Midfielder", "Hungary", "EPL-LIV-SZOBOSZLAI", 85),
            player("Ibrahima Konate", "Defender", "France", "EPL-LIV-KONATE", 85),
            player("Cody Gakpo", "Forward", "Netherlands", "EPL-LIV-GAKPO", 84),
            player("Curtis Jones", "Midfielder", "England", "EPL-LIV-CJONES", 83),
            player("Victor Munoz", "Forward", "Spain", "EPL-LIV-VMUNOZ", 81)
          ]
        },
        %{
          name: "Arsenal",
          country: "England",
          external_id: "EPL-ARS",
          players: [
            player("Bukayo Saka", "Forward", "England", "EPL-ARS-SAKA", 88),
            player("Martin Odegaard", "Midfielder", "Norway", "EPL-ARS-ODEGAARD", 89),
            player("William Saliba", "Defender", "France", "EPL-ARS-SALIBA", 90),
            player("Declan Rice", "Midfielder", "England", "EPL-ARS-RICE", 89),
            player("Gabriel Magalhaes", "Defender", "Brazil", "EPL-ARS-GABRIEL", 88),
            player("Kai Havertz", "Forward", "Germany", "EPL-ARS-HAVERTZ", 86),
            player("David Raya", "Goalkeeper", "Spain", "EPL-ARS-RAYA", 86),
            player("Piero Hincapie", "Defender", "Ecuador", "EPL-ARS-HINCAPIE", 85),
            player("Ben White", "Defender", "England", "EPL-ARS-BWHITE", 84),
            player("Gabriel Martinelli", "Forward", "Brazil", "EPL-ARS-MARTINELLI", 84),
            player("Riccardo Calafiori", "Defender", "Italy", "EPL-ARS-CALAFIORI", 84),
            player("Jurrien Timber", "Defender", "Netherlands", "EPL-ARS-TIMBER", 83),
            player("Mikel Merino", "Midfielder", "Spain", "EPL-ARS-MERINO", 83),
            player("Leandro Trossard", "Forward", "Belgium", "EPL-ARS-TROSSARD", 82)
          ]
        },
        %{
          name: "Manchester United",
          country: "England",
          external_id: "EPL-MUN",
          players: [
            player("Bruno Fernandes", "Midfielder", "Portugal", "EPL-MUN-BFERNANDES", 89),
            player("Kobbie Mainoo", "Midfielder", "England", "EPL-MUN-MAINOO", 85),
            player("Matthijs de Ligt", "Defender", "Netherlands", "EPL-MUN-DELIGT", 84),
            player("Lisandro Martinez", "Defender", "Argentina", "EPL-MUN-LMARTINEZ", 86),
            player("Marcus Rashford", "Forward", "England", "EPL-MUN-RASHFORD", 83),
            player("Diogo Dalot", "Defender", "Portugal", "EPL-MUN-DALOT", 83),
            player("Amad Diallo", "Forward", "Cote d'Ivoire", "EPL-MUN-AMAD", 83),
            player("Noussair Mazraoui", "Defender", "Morocco", "EPL-MUN-MAZRAOUI", 82),
            player("Joshua Zirkzee", "Forward", "Netherlands", "EPL-MUN-ZIRKZEE", 82),
            player("Leny Yoro", "Defender", "France", "EPL-MUN-YORO", 82),
            player("Luke Shaw", "Defender", "England", "EPL-MUN-SHAW", 79),
            player("Altay Bayindir", "Goalkeeper", "Turkey", "EPL-MUN-BAYINDIR", 78)
          ]
        },
        %{
          name: "Chelsea",
          country: "England",
          external_id: "EPL-CHE",
          players: [
            player("Cole Palmer", "Midfielder", "England", "EPL-CHE-PALMER", 87),
            player("Moises Caicedo", "Midfielder", "Ecuador", "EPL-CHE-CAICEDO", 86),
            player("Enzo Fernandez", "Midfielder", "Argentina", "EPL-CHE-ENZO", 85),
            player("Nicolas Jackson", "Forward", "Senegal", "EPL-CHE-JACKSON", 83),
            player("Levi Colwill", "Defender", "England", "EPL-CHE-COLWILL", 84),
            player("Christopher Nkunku", "Forward", "France", "EPL-CHE-NKUNKU", 83),
            player("Noni Madueke", "Forward", "England", "EPL-CHE-MADUEKE", 83),
            player("Pedro Neto", "Forward", "Portugal", "EPL-CHE-PNETO", 83),
            player("Geovany Quenda", "Forward", "Portugal", "EPL-CHE-QUENDA", 80),
            player("Malo Gusto", "Defender", "France", "EPL-CHE-GUSTO", 82),
            player("Reece James", "Defender", "England", "EPL-CHE-RJAMES", 81),
            player("Robert Sanchez", "Goalkeeper", "Spain", "EPL-CHE-RSANCHEZ", 81),
            player("Marco Palestra", "Defender", "Italy", "EPL-CHE-PALESTRA", 80),
            player("Filip Jorgensen", "Goalkeeper", "Denmark", "EPL-CHE-JORGENSEN", 80)
          ]
        },
        %{
          name: "Tottenham Hotspur",
          country: "England",
          external_id: "EPL-TOT",
          players: [
            player("Sandro Tonali", "Midfielder", "Italy", "EPL-TOT-TONALI", 86),
            player("James Maddison", "Midfielder", "England", "EPL-TOT-MADDISON", 85),
            player("Cristian Romero", "Defender", "Argentina", "EPL-TOT-ROMERO", 85),
            player("Dejan Kulusevski", "Forward", "Sweden", "EPL-TOT-KULUSEVSKI", 85),
            player("Micky van de Ven", "Defender", "Netherlands", "EPL-TOT-VANDEVEN", 85),
            player("Guglielmo Vicario", "Goalkeeper", "Italy", "EPL-TOT-VICARIO", 84),
            player("Dominic Solanke", "Forward", "England", "EPL-TOT-SOLANKE", 83),
            player("Pedro Porro", "Defender", "Spain", "EPL-TOT-PORRO", 84),
            player("Brennan Johnson", "Forward", "Wales", "EPL-TOT-JOHNSON", 83),
            player("Mateus Fernandes", "Midfielder", "Portugal", "EPL-TOT-MFERNANDES", 82),
            player("Marcos Senesi", "Defender", "Argentina", "EPL-TOT-SENESI", 81),
            player("Mikey Moore", "Forward", "England", "EPL-TOT-MOORE", 80)
          ]
        },
        %{
          name: "Aston Villa",
          country: "England",
          external_id: "EPL-AVL",
          players: [
            player("Emiliano Martinez", "Goalkeeper", "Argentina", "EPL-AVL-EMARTINEZ", 87),
            player("Ollie Watkins", "Forward", "England", "EPL-AVL-WATKINS", 85),
            player("Ezri Konsa", "Defender", "England", "EPL-AVL-KONSA", 84),
            player("Pau Torres", "Defender", "Spain", "EPL-AVL-PTORRES", 84),
            player("John McGinn", "Midfielder", "Scotland", "EPL-AVL-MCGINN", 83),
            player("Amadou Onana", "Midfielder", "Belgium", "EPL-AVL-AONANA", 83),
            player("Morgan Rogers", "Midfielder", "England", "EPL-AVL-ROGERS", 83),
            player("Jhon Duran", "Forward", "Colombia", "EPL-AVL-DURAN", 83),
            player("Youri Tielemans", "Midfielder", "Belgium", "EPL-AVL-TIELEMANS", 82),
            player("Leon Bailey", "Forward", "Jamaica", "EPL-AVL-BAILEY", 81),
            player("Boubacar Kamara", "Midfielder", "France", "EPL-AVL-KAMARA", 81),
            player("Ian Maatsen", "Defender", "Netherlands", "EPL-AVL-MAATSEN", 81),
            player("Lucas Digne", "Defender", "France", "EPL-AVL-DIGNE", 80),
            player("Matty Cash", "Defender", "Poland", "EPL-AVL-CASH", 79)
          ]
        },
        %{
          name: "Newcastle United",
          country: "England",
          external_id: "EPL-NEW",
          players: [
            player("Sven Botman", "Defender", "Netherlands", "EPL-NEW-BOTMAN", 84),
            player("Nick Pope", "Goalkeeper", "England", "EPL-NEW-POPE", 83),
            player("Kieran Trippier", "Defender", "England", "EPL-NEW-TRIPPIER", 81),
            player("Bazoumana Toure", "Forward", "Cote d'Ivoire", "EPL-NEW-TOURE", 80)
          ]
        },
        %{
          name: "Brighton & Hove Albion",
          country: "England",
          external_id: "EPL-BHA",
          players: [
            player("Kaoru Mitoma", "Forward", "Japan", "EPL-BHA-MITOMA", 84),
            player("Bart Verbruggen", "Goalkeeper", "Netherlands", "EPL-BHA-VERBRUGGEN", 82),
            player("Pascal Struijk", "Defender", "Netherlands", "EPL-BHA-STRUIJK", 81),
            player("Lewis Dunk", "Defender", "England", "EPL-BHA-DUNK", 80)
          ]
        },
        %{
          name: "AFC Bournemouth",
          country: "England",
          external_id: "EPL-BOU",
          players: [
            player("Illia Zabarnyi", "Defender", "Ukraine", "EPL-BOU-ZABARNYI", 82),
            player("Antoine Semenyo", "Forward", "Ghana", "EPL-BOU-SEMENYO", 81),
            player("Milos Kerkez", "Defender", "Hungary", "EPL-BOU-KERKEZ", 80),
            player("Justin Kluivert", "Forward", "Netherlands", "EPL-BOU-KLUIVERT", 79)
          ]
        },
        %{
          name: "Brentford",
          country: "England",
          external_id: "EPL-BRE",
          players: [
            player("Christian Norgaard", "Midfielder", "Denmark", "EPL-BRE-NORGAARD", 80),
            player("Yoane Wissa", "Forward", "DR Congo", "EPL-BRE-WISSA", 80),
            player("Jaidon Anthony", "Forward", "England", "EPL-BRE-ANTHONY", 76)
          ]
        },
        %{
          name: "Coventry City",
          country: "England",
          external_id: "EPL-COV",
          players: [
            player("Haji Wright", "Forward", "United States", "EPL-COV-WRIGHT", 78),
            player("Frank Onyeka", "Midfielder", "Nigeria", "EPL-COV-ONYEKA", 77),
            player("Ben Sheaf", "Midfielder", "England", "EPL-COV-SHEAF", 76),
            player("Ellis Simms", "Forward", "England", "EPL-COV-SIMMS", 75)
          ]
        },
        %{
          name: "Crystal Palace",
          country: "England",
          external_id: "EPL-CRY",
          players: [
            player("Jean-Philippe Mateta", "Forward", "France", "EPL-CRY-MATETA", 81),
            player("Adam Wharton", "Midfielder", "England", "EPL-CRY-WHARTON", 81)
          ]
        },
        %{
          name: "Everton",
          country: "England",
          external_id: "EPL-EVE",
          players: [
            player("Jordan Pickford", "Goalkeeper", "England", "EPL-EVE-PICKFORD", 83),
            player("James Tarkowski", "Defender", "England", "EPL-EVE-TARKOWSKI", 79),
            player("Hayden Hackney", "Midfielder", "England", "EPL-EVE-HACKNEY", 78),
            player("Tyrique George", "Forward", "England", "EPL-EVE-GEORGE", 76)
          ]
        },
        %{
          name: "Fulham",
          country: "England",
          external_id: "EPL-FUL",
          players: [
            player("Antonee Robinson", "Defender", "United States", "EPL-FUL-ROBINSON", 82),
            player("Andreas Pereira", "Midfielder", "Brazil", "EPL-FUL-PEREIRA", 80),
            player("Alex Iwobi", "Midfielder", "Nigeria", "EPL-FUL-IWOBI", 78),
            player("Jonah Kusi-Asare", "Forward", "Sweden", "EPL-FUL-KUSIASARE", 76)
          ]
        },
        %{
          name: "Hull City",
          country: "England",
          external_id: "EPL-HUL",
          players: [
            player("Abdülkadir Ömür", "Midfielder", "Turkey", "EPL-HUL-OMUR", 77),
            player("Jack Butland", "Goalkeeper", "England", "EPL-HUL-BUTLAND", 76),
            player("Regan Slater", "Midfielder", "England", "EPL-HUL-SLATER", 74),
            player("Lewie Coyle", "Defender", "England", "EPL-HUL-COYLE", 73)
          ]
        },
        %{
          name: "Ipswich Town",
          country: "England",
          external_id: "EPL-IPS",
          players: [
            player("Omari Hutchinson", "Forward", "Jamaica", "EPL-IPS-HUTCHINSON", 79),
            player("Jacob Greaves", "Defender", "England", "EPL-IPS-GREAVES", 78),
            player("Chuba Akpom", "Forward", "England", "EPL-IPS-AKPOM", 76),
            player("Emersonn", "Forward", "Brazil", "EPL-IPS-EMERSONN", 75)
          ]
        },
        %{
          name: "Leeds United",
          country: "England",
          external_id: "EPL-LEE",
          players: [
            player("Illan Meslier", "Goalkeeper", "France", "EPL-LEE-MESLIER", 79),
            player("Ethan Ampadu", "Midfielder", "Wales", "EPL-LEE-AMPADU", 78),
            player("Wilfried Gnonto", "Forward", "Italy", "EPL-LEE-GNONTO", 78),
            player("Harry Wilson", "Forward", "Wales", "EPL-LEE-WILSON", 77)
          ]
        },
        %{
          name: "Nottingham Forest",
          country: "England",
          external_id: "EPL-NFO",
          players: [
            player("Morgan Gibbs-White", "Midfielder", "England", "EPL-NFO-MGW", 83),
            player("Murillo", "Defender", "Brazil", "EPL-NFO-MURILLO", 83),
            player("Callum Hudson-Odoi", "Forward", "England", "EPL-NFO-HUDSONODOI", 80),
            player("Taiwo Awoniyi", "Forward", "Nigeria", "EPL-NFO-AWONIYI", 78)
          ]
        },
        %{
          name: "Sunderland",
          country: "England",
          external_id: "EPL-SUN",
          players: [
            player("Jobe Bellingham", "Midfielder", "England", "EPL-SUN-BELLINGHAM", 79),
            player("Anthony Patterson", "Goalkeeper", "England", "EPL-SUN-PATTERSON", 77),
            player("Dan Ballard", "Defender", "Northern Ireland", "EPL-SUN-BALLARD", 76),
            player("Patrick Roberts", "Forward", "England", "EPL-SUN-ROBERTS", 74)
          ]
        }
      ]
    }
  end

  defp player(name, position, nationality, external_id, rating) do
    %{
      name: name,
      position: position,
      nationality: nationality,
      birth_date: nil,
      birth_city: nil,
      external_id: external_id,
      rating: rating,
      rating_season: "2026"
    }
  end
end
