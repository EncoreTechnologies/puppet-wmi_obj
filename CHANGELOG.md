# Changelog

All notable changes to this project will be documented in this file.

## Release v1.1.0
- Convert to PDK
- Convert to GitHub Actions
- Fix type generation for `wmi_class_purge`

  Contributed by Nick Maludy (@nmaludy)

## Release v1.0.2
- Change perms on metadata.json, which seems not to be handled by puppet module tool correctly

## Release v1.0.1
- Remove some lingering ruby 1.9 syntax
- Fix (possibly inconsequential) typo 

## Release v1.0.0
- Removed need for ruby 1.9+
- `wmi_class_purge` uses all key properties in the `title` field to help avoid name collisions
