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
            player("Erling Haaland", "Forward", "Norway", "EPL-MCI-HAALAND", 91),
            player("Rodri", "Midfielder", "Spain", "EPL-MCI-RODRI", 90),
            player("Phil Foden", "Midfielder", "England", "EPL-MCI-FODEN", 88),
            player("Ruben Dias", "Defender", "Portugal", "EPL-MCI-DIAS", 88),
            player("Ederson", "Goalkeeper", "Brazil", "EPL-MCI-EDERSON", 87),
            player("Bernardo Silva", "Midfielder", "Portugal", "EPL-MCI-BSILVA", 88),
            player("Kevin De Bruyne", "Midfielder", "Belgium", "EPL-MCI-KDB", 90),
            player("Jeremy Doku", "Forward", "Belgium", "EPL-MCI-DOKU", 83),
            player("Jack Grealish", "Forward", "England", "EPL-MCI-GREALISH", 84),
            player("John Stones", "Defender", "England", "EPL-MCI-STONES", 86),
            player("Josko Gvardiol", "Defender", "Croatia", "EPL-MCI-GVARDIOL", 85),
            player("Kyle Walker", "Defender", "England", "EPL-MCI-WALKER", 84),
            player("Mateo Kovacic", "Midfielder", "Croatia", "EPL-MCI-KOVACIC", 83),
            player("Savinho", "Forward", "Brazil", "EPL-MCI-SAVINHO", 82),
            player("Manuel Akanji", "Defender", "Switzerland", "EPL-MCI-AKANJI", 84)
          ]
        },
        %{
          name: "Liverpool",
          country: "England",
          external_id: "EPL-LIV",
          players: [
            player("Mohamed Salah", "Forward", "Egypt", "EPL-LIV-SALAH", 90),
            player("Virgil van Dijk", "Defender", "Netherlands", "EPL-LIV-VVD", 89),
            player("Alisson", "Goalkeeper", "Brazil", "EPL-LIV-ALISSON", 89),
            player("Alexis Mac Allister", "Midfielder", "Argentina", "EPL-LIV-MACALLISTER", 86),
            player("Trent Alexander-Arnold", "Defender", "England", "EPL-LIV-TAA", 86),
            player("Dominik Szoboszlai", "Midfielder", "Hungary", "EPL-LIV-SZOBOSZLAI", 85),
            player("Luis Diaz", "Forward", "Colombia", "EPL-LIV-LDIAZ", 85),
            player("Diogo Jota", "Forward", "Portugal", "EPL-LIV-JOTA", 85),
            player("Darwin Nunez", "Forward", "Uruguay", "EPL-LIV-NUNEZ", 84),
            player("Andy Robertson", "Defender", "Scotland", "EPL-LIV-ROBERTSON", 85),
            player("Ibrahima Konate", "Defender", "France", "EPL-LIV-KONATE", 84),
            player("Curtis Jones", "Midfielder", "England", "EPL-LIV-CJONES", 82),
            player("Ryan Gravenberch", "Midfielder", "Netherlands", "EPL-LIV-GRAVENBERCH", 83),
            player("Cody Gakpo", "Forward", "Netherlands", "EPL-LIV-GAKPO", 84),
            player("Conor Bradley", "Defender", "Northern Ireland", "EPL-LIV-BRADLEY", 79)
          ]
        },
        %{
          name: "Arsenal",
          country: "England",
          external_id: "EPL-ARS",
          players: [
            player("Bukayo Saka", "Forward", "England", "EPL-ARS-SAKA", 89),
            player("Martin Odegaard", "Midfielder", "Norway", "EPL-ARS-ODEGAARD", 88),
            player("Declan Rice", "Midfielder", "England", "EPL-ARS-RICE", 87),
            player("William Saliba", "Defender", "France", "EPL-ARS-SALIBA", 87),
            player("David Raya", "Goalkeeper", "Spain", "EPL-ARS-RAYA", 84),
            player("Kai Havertz", "Forward", "Germany", "EPL-ARS-HAVERTZ", 85),
            player("Gabriel Martinelli", "Forward", "Brazil", "EPL-ARS-MARTINELLI", 84),
            player("Gabriel Jesus", "Forward", "Brazil", "EPL-ARS-JESUS", 84),
            player("Leandro Trossard", "Forward", "Belgium", "EPL-ARS-TROSSARD", 83),
            player("Ben White", "Defender", "England", "EPL-ARS-BWHITE", 84),
            player("Gabriel Magalhaes", "Defender", "Brazil", "EPL-ARS-GABRIEL", 85),
            player("Jurrien Timber", "Defender", "Netherlands", "EPL-ARS-TIMBER", 83),
            player("Viktor Gyökeres", "Forward", "Sweden", "EPL-ARS-GYOKERES", 85),
            player("Mikel Merino", "Midfielder", "Spain", "EPL-ARS-MERINO", 83),
            player("Riccardo Calafiori", "Defender", "Italy", "EPL-ARS-CALAFIORI", 82)
          ]
        },
        %{
          name: "Manchester United",
          country: "England",
          external_id: "EPL-MUN",
          players: [
            player("Bruno Fernandes", "Midfielder", "Portugal", "EPL-MUN-BFERNANDES", 87),
            player("Andre Onana", "Goalkeeper", "Cameroon", "EPL-MUN-ONANA", 83),
            player("Lisandro Martinez", "Defender", "Argentina", "EPL-MUN-LMARTINEZ", 84),
            player("Matthijs de Ligt", "Defender", "Netherlands", "EPL-MUN-DELIGT", 84),
            player("Casemiro", "Midfielder", "Brazil", "EPL-MUN-CASEMIRO", 84),
            player("Kobbie Mainoo", "Midfielder", "England", "EPL-MUN-MAINOO", 82),
            player("Mason Mount", "Midfielder", "England", "EPL-MUN-MOUNT", 82),
            player("Amad Diallo", "Forward", "Cote d'Ivoire", "EPL-MUN-AMAD", 81),
            player("Rasmus Hojlund", "Forward", "Denmark", "EPL-MUN-HOJLUND", 82),
            player("Alejandro Garnacho", "Forward", "Argentina", "EPL-MUN-GARNACHO", 83),
            player("Joshua Zirkzee", "Forward", "Netherlands", "EPL-MUN-ZIRKZEE", 81),
            player("Diogo Dalot", "Defender", "Portugal", "EPL-MUN-DALOT", 82),
            player("Luke Shaw", "Defender", "England", "EPL-MUN-SHAW", 81),
            player("Harry Maguire", "Defender", "England", "EPL-MUN-MAGUIRE", 80),
            player("Noussair Mazraoui", "Defender", "Morocco", "EPL-MUN-MAZRAOUI", 81)
          ]
        },
        %{
          name: "Chelsea",
          country: "England",
          external_id: "EPL-CHE",
          players: [
            player("Cole Palmer", "Midfielder", "England", "EPL-CHE-PALMER", 87),
            player("Enzo Fernandez", "Midfielder", "Argentina", "EPL-CHE-ENZO", 84),
            player("Moises Caicedo", "Midfielder", "Ecuador", "EPL-CHE-CAICEDO", 84),
            player("Reece James", "Defender", "England", "EPL-CHE-RJAMES", 84),
            player("Levi Colwill", "Defender", "England", "EPL-CHE-COLWILL", 82),
            player("Wesley Fofana", "Defender", "France", "EPL-CHE-FOFANA", 82),
            player("Marc Cucurella", "Defender", "Spain", "EPL-CHE-CUCURELLA", 81),
            player("Malo Gusto", "Defender", "France", "EPL-CHE-GUSTO", 80),
            player("Noni Madueke", "Forward", "England", "EPL-CHE-MADUEKE", 81),
            player("Mykhailo Mudryk", "Forward", "Ukraine", "EPL-CHE-MUDRYK", 79),
            player("Nicolas Jackson", "Forward", "Senegal", "EPL-CHE-JACKSON", 81),
            player("Christopher Nkunku", "Forward", "France", "EPL-CHE-NKUNKU", 84),
            player("Pedro Neto", "Forward", "Portugal", "EPL-CHE-PNETO", 82),
            player("Robert Sanchez", "Goalkeeper", "Spain", "EPL-CHE-RSANCHEZ", 80),
            player("Filip Jorgensen", "Goalkeeper", "Denmark", "EPL-CHE-JORGENSEN", 78)
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
