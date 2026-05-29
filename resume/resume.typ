#import "@preview/basic-resume:0.2.9": *
#import "@preview/cmarker:0.1.8": render as md
#import "@preview/oxifmt:1.0.0": strfmt

#let formatDateString(s) = toml(bytes("date = " + s + "-01")).date.display("[month repr:short] [year]")
#let myResume = yaml("resume.yaml")

#show: resume.with(
  author: myResume.name,
  location: myResume.location,
  email: myResume.email,
  github: myResume.github,
  phone: myResume.phone,
  personal-site: myResume.website,
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: center,
  personal-info-position: center,
)

== Education

#for educationItem in myResume.education [
  #edu(
    institution: educationItem.institution,
    location: educationItem.location,
    degree: strfmt("{}, {} GPA", educationItem.degree, educationItem.gpa),
    dates: dates-helper(
      start-date: formatDateString(educationItem.start_date),
      end-date: formatDateString(educationItem.end_date),
    ),
    consistent: true,
  )
  #list(..educationItem.extra.map(md))
]

== Work Experience

#for workItem in myResume.work [
  #work(
    title: workItem.title,
    location: workItem.location,
    company: workItem.company,
    dates: dates-helper(
      start-date: formatDateString(workItem.start_date),
      end-date: if "end_date" in workItem {
        formatDateString(workItem.end_date)
      } else {
        "Present"
      }
    )
  )
  #list(..workItem.extra.map(md))
]

== Projects

#for projectItem in myResume.projects [
  #project(
    name: projectItem.name,
    dates: formatDateString(projectItem.date),
    url: projectItem.url,
  )
  #list(..projectItem.extra.map(md))
]

== Skills

#list(..myResume.skills.map(skillItem => [
  *#skillItem.category*: #skillItem.items.join([, ])
]))

