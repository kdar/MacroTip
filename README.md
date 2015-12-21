MacroTip
========

A WoW addon that enables you to make macros for talents or other spells, and have
the correct icon/cooldown for it.

Normally you would do something like this:

    #showtooltip
    /cast Blood Horror
    /cast Burning Rush
    /cast Unbound Will
    /run local G=GetSpellInfo SetMacroSpell("tier4", G"Blood Horror" or G"Burning Rush" or "Unbound Will")

The issue with this is you have to hit the spell to see the cooldown, and sometimes it would randomly reset and have a red question mark.

To use MacroTip, you basically add a comment in your macro with configuration telling MacroTip what spell it should set the macro as.

## Examples

For example, if you want a macro for Avatar, Bloodbath, and Bladestorm, you do:

    #macrotip tier6
    /cast Avatar
    /cast Bloodbath
    /cast Bladestorm

The "tier6" part tells MacroTip to use the talents on tier 6 (e.g. the level 90 talents).

You can also specify exactly what spells the macro might contain:

    #macrotip Storm Bolt,Shockwave,Dragon Roar
    /cast [mod:ctrl, @focus] Storm Bolt; Storm Bolt
    /cast Shockwave
    /cast Dragon Roar

Here, after #macrotip, just list all the spells you want in a list separated by commas. The first spell it finds that you are able to cast, it will set it as the macro icon.

This is also useful for talents that have different spells from their names. For example, the warlock talent Grimoire of Service actually has 5 spells associated with it: Grimoire: Imp, Grimoire: Voidwalker, etc.. So you can have a macro like this:

    #macrotip Grimoire: Felhunter,Spell2,Spell3
    /cast Grimoire: Felhunter
    /cast Spell2
    /cast Spell3

## Syntax

    #macrotip <config>

where <config> can be the following (in regex format):

    tier[1-7]
    (Spell,?)+

# Notes

I use the name tier1-7 and not "talents90" or "level90" because some classes (dk, demon hunter) don't follow the same pattern as other classes. So this makes it more consistent.

# Similar Addons

MacroTooltipLoader - it attempts to solve the same problem as MacroTip, except it edits your macro directly and replaces it with predefined spells and #showtooltip. If you want different stuff in your macro, you have to edit the lua.
