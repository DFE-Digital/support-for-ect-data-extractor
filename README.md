# Support for ECT CMS extractor 🚛

This is a program which will convert the content from [Support for early career teachers](https://support-for-early-career-teachers.education.gov.uk/) into plain Markdown. It will be short lived and discarded once the migration is done.

The data is stored in a database and has a custom CMS built in Rails. It is clunky, complicated and unmaintained.

Moving it to a static website will make maintaining and updating it easier and remove the cost and complexity required to host it.

See [extract.rb](extract.rb) for more details.

## CMS Schema

```mermaid
erDiagram
    core_induction_programmes {
        timestamp_without_time_zone created_at
        uuid id PK
        character_varying name
        character_varying slug
        timestamp_without_time_zone updated_at
    }

    course_lesson_parts {
        text content
        uuid course_lesson_id FK
        timestamp_without_time_zone created_at
        uuid id PK
        uuid previous_lesson_part_id FK
        character_varying title
        timestamp_without_time_zone updated_at
    }

    course_lessons {
        integer completion_time_in_minutes
        uuid course_module_id FK
        timestamp_without_time_zone created_at
        text ect_summary
        character_varying ect_teacher_standards
        uuid id PK
        text mentor_summary
        character_varying mentor_teacher_standards
        character_varying mentor_title
        integer position
        uuid previous_lesson_id FK
        character_varying title
        timestamp_without_time_zone updated_at
    }

    course_modules {
        uuid course_year_id FK
        timestamp_without_time_zone created_at
        text ect_summary
        uuid id PK
        text mentor_summary
        character_varying page_header
        uuid previous_module_id FK
        character_varying term
        character_varying title
        timestamp_without_time_zone updated_at
    }

    course_years {
        text content
        uuid core_induction_programme_id FK
        timestamp_without_time_zone created_at
        uuid id PK
        character_varying mentor_title
        integer position
        character_varying title
        timestamp_without_time_zone updated_at
    }

    mentor_material_parts {
        text content
        timestamp_without_time_zone created_at
        uuid id PK
        uuid mentor_material_id FK
        uuid previous_mentor_material_part_id FK
        character_varying title
        timestamp_without_time_zone updated_at
    }

    mentor_materials {
        integer completion_time_in_minutes
        uuid course_lesson_id FK
        timestamp_without_time_zone created_at
        uuid id PK
        integer position
        character_varying title
        timestamp_without_time_zone updated_at
    }

    course_years }o--|| core_induction_programmes : "core_induction_programme_id"
    course_lesson_parts }o--|| course_lesson_parts : "previous_lesson_part_id"
    course_lesson_parts }o--|| course_lessons : "course_lesson_id"
    course_lessons }o--|| course_lessons : "previous_lesson_id"
    course_lessons }o--|| course_modules : "course_module_id"
    mentor_materials }o--|| course_lessons : "course_lesson_id"
    course_modules }o--|| course_modules : "previous_module_id"
    course_modules }o--|| course_years : "course_year_id"
    mentor_material_parts }o--|| mentor_material_parts : "previous_mentor_material_part_id"
    mentor_material_parts }o--|| mentor_materials : "mentor_material_id"
```
