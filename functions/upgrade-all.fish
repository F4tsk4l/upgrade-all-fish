function upgrade-all
    function show_help
        echo "Usage:"
        echo "  upgrade-all -A    Dynamic Sync and full upgrade (Pacman, Yay, Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
        echo "  upgrade-all -a    Perform partial upgrade (Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
        echo "  upgrade-all -h    Display this help message"
    end

    if set -q argv[1]
        switch "$argv[1]"
            #NOTE: Run this once to to save to config file.
            #yay -Syudd --sudoloop --cleanafter --answeredit None --answerdiff None --answerclean None --noconfirm
            case -A
                echo "Full upgrade selected (Yay, Ya(Yazi), Cargo, Nvim_Plugins, Pipx, Fisher)"

                # Yay package database sync interval in hours
                # Default: 6 hours
                if not set -q upgrade_all_sync_interval
                    set -U upgrade_all_sync_interval 6
                end

                set -l sync_interval (math "$upgrade_all_sync_interval * 3600")
                set -l sync_stamp "$HOME/.cache/upgrade-all-fish-sync"

                # Create cache directory if it doesn't exist
                mkdir -p (dirname "$sync_stamp")

                set -l yay_sync 0
                set -l remaining 0

                if test -f "$sync_stamp"
                    set -l last_sync (cat "$sync_stamp")
                    set -l now (date +%s)
                    set -l elapsed (math "$now - $last_sync")
                    set remaining (math "$sync_interval - $elapsed")

                    if test $elapsed -lt $sync_interval
                        set yay_sync 1
                    end
                end

                if test $yay_sync -eq 1
                    # Convert remaining seconds to a human-readable format
                    set -l days (math "floor($remaining / 86400)")
                    set -l hours (math "floor(($remaining % 86400) / 3600)")
                    set -l minutes (math "floor(($remaining % 3600) / 60)")

                    set -l time_left ""

                    if test $days -gt 0
                        set time_left "$days"d
                    end

                    if test $hours -gt 0
                        set time_left "$time_left $hours"h
                    end

                    if test $minutes -gt 0
                        set time_left "$time_left $minutes"m
                    end

                    # Trim leading space
                    set time_left (string trim "$time_left")

                    echo "Yay database sync skipped."
                    echo "Next sync in $time_left. Running yay -Sudd..."

                    yay -Sudd \
                        --sudoloop \
                        --cleanafter \
                        --answeredit None \
                        --answerdiff None \
                        --answerclean None \
                        --noconfirm
                else
                    echo "Yay database sync interval expired. Running yay -Syudd..."

                    yay -Syudd \
                        --sudoloop \
                        --cleanafter \
                        --answeredit None \
                        --answerdiff None \
                        --answerclean None \
                        --noconfirm

                    # Only update timestamp when the sync succeeds
                    if test $status -eq 0
                        date +%s >"$sync_stamp"
                    else
                        echo "Yay database sync failed."
                        echo "Sync timestamp was not updated."
                        return 1
                    end
                end

                and ya pkg upgrade
                and nvim --headless "+Lazy! update" +qa
                and cargo install-update -a
                and pipx upgrade-all
                and fisher update

            case -a
                echo "Partial upgrade selected (Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
                ya pkg upgrade
                and fisher update
                and cargo install-update -a
                and nvim --headless "+Lazy! update" +qa
                and pipx upgrade-all
            case -h
                show_help
                return 0
            case '*'
                echo "Invalid option. Use -h for help."
                return 1
        end
    else
        echo "No option provided. Use -h for help."
        return 1
    end
end
