# Randomly select warmup excercise
from ntpath import join
from os import curdir, listdir, mkdir
from posixpath import abspath, dirname
from random import choice, randint, seed
from datetime import datetime

now = datetime.now()
seed(now.hour + now.minute + now.second + now.microsecond)

NO_EXCERCISES = 3

QUIZES_DIR_NAME = "Quizes"
QUIZES_DIR_PATH = join(dirname(abspath(__file__)), QUIZES_DIR_NAME)

SUMMARY_FILE_NAME = "README.md"
SUMMARY_FILE_PATH = join(QUIZES_DIR_PATH, SUMMARY_FILE_NAME)

PDF_PAGE_INCREMENT = 8
NO_EXCERCISES_ID, PAGES_ID, CHAPTER_NUMBER_ID, CHAPTER_TITLE_ID = 0, 1, 2, 3


book = [
    # (NO_EXCERCISES_ID, PAGES_ID, CHAPTER_NUMBER_ID, CHAPTER_TITLE_ID),    
    (11, "1-30", 1, "Fundamental Concepts"),
    (13, "31-64", 2, "Scalar Data Types and Operations"),
    (15, "65-94", 3, "Sequential Statements"),
    (13, "95-135", 4, "Composite Data Types and Operations"),
    (41, "137-205", 5, "Basic Modeling Constructs"),
    (22, "207-243", 6, "Subprograms"),
    # (, "245-265", 7, "Packages and Use Clauses"),
    # (, "267-292", 8, "Resolved Signals"),
    # (, "293-336", 9, "Predefined and Standard Packages"),
    # (, "337-354", 10, "Case Study: A Pipelined Multiplier Accumulator"),
    # (, "355-364", 11, "Aliases"),
    # (, "365-416", 12, "Generics"),
    # (, "417-448", 13, "Components and Configurations"),
    # (, "449-478", 14, "Generate Statements"),
    # (, "479-498", 15, "Access Types"),
    # (, "499-533", 16, "Files and Input/Output"),
    # (, "535-558", 17, "Case Study: A Package for Memories"),
    # (, "559-583", 18, "Test Bench and Verification Features"),
    # (, "585-602", 19, "Shared Variables and Protected Types"),
    # (, "603-632", 20, "Attributes and Groups"),
    # (, "633-668", 21, "Design for Synthesis"),
    # (, "669-732", 22, "Case Study: System Design Using the Gumnut Core"),
    # (, "733-791", 23, "Miscellaneous Topics1")

    #    -    "Appendix A - "
    #    -    "Appendix B - VHDL Syntax"
    # 859-888 "Appendix C - Answers"
    # 889-890 "References"
    # 891-910 "Index"
]


def pick_excercise() -> str:
    # Select chapter
    chapter = choice(book)
    # Select excercise
    no_ex = chapter[NO_EXCERCISES_ID]
    ex = randint(1, no_ex)
    # Pages
    last_page = int(chapter[PAGES_ID].split('-')[-1])
    last_page_pdf = last_page+PDF_PAGE_INCREMENT
    # Show info
    full_name = f"[B:{last_page:3d}|PDF:{last_page_pdf:3d}] Chapter {chapter[CHAPTER_NUMBER_ID]} \"{chapter[CHAPTER_TITLE_ID]}\" - Ex. {ex}"
    short_name = f"Ch{chapter[CHAPTER_NUMBER_ID]}_Ex{ex}"
    return full_name, short_name


def create_quiz() -> None:
    # Get list of tasks
    tasks = [pick_excercise() for _ in range(NO_EXCERCISES)]

    # Check highest number for sub_dir
    files = listdir(join(QUIZES_DIR_PATH))
    max_num = int(max(files, key=lambda name: int(name) if name.isnumeric() else 0)) if files else 0

    # Create new subdir
    sdir_path = join(QUIZES_DIR_PATH, str(max_num+1))
    mkdir(sdir_path)

    # Create vhd files
    for full_name, short_name in tasks:
        fpath = join(sdir_path, short_name + '.vhd')
        # Content
        lines = [
            '-- ' + full_name,
            '-- Task: ',
            '',
            '-- Answer:',
            ''
        ]
        content = '\n'.join(lines)

        with open(fpath, 'w') as f:
            f.write(content)

    # Append info to summmary file
    full_names = [full_name for full_name, _ in tasks]
    content = f'---\n### *{str(now)}*\n* ' + '\n* '.join(full_names) + '\n'

    with open(SUMMARY_FILE_PATH, 'a') as f:
        f.write(content)


    pass


create_quiz()
