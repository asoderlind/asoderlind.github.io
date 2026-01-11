---
title: "Archive"
layout: page
permalink: /archive/
---

{% assign postsByYear = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}

{% for year in postsByYear %}
## {{ year.name }}

<ul class="post-list">
{% for post in year.items %}
  <li>
    <div class="post-item">
      <span class="post-date">{{ post.date | date: "%Y-%m-%d" }}</span>
      <a href="{{ post.url | relative_url }}" class="post-link">{{ post.title }}</a>
    </div>
  </li>
{% endfor %}
</ul>

{% endfor %}
