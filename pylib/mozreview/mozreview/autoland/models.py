from __future__ import unicode_literals

from django.db import models
from django.utils.translation import ugettext_lazy as _
from djblets.db.fields import JSONField


class AutolandRequest(models.Model):
    autoland_id = models.IntegerField(
        primary_key=True,
        help_text=_('The job ID that Autoland returns to us.'))
    push_revision = models.CharField(
        max_length=40,
        help_text=_('The revision ID of the commit that Autoland was asked to '
                    'land.'),
        db_index=True)
    repository_url = models.CharField(
        max_length=255,
        blank=True,
        default='',
        help_text=_('The URL of the repository that Autoland landed on.'))
    repository_revision = models.CharField(
        max_length=40,
        blank=True,
        default='',
        help_text=_('The revision ID of the commit that Autoland landed.'),
        db_index=True)
    # Unfortunately, Review Board extensions can't take advantage of the
    # ForeignKey ORM magic that Django provides. This is because the extension
    # loading mechanism doesn't do enough (yet) to flush out the foreign key
    # caches in Django.
    review_request_id = models.IntegerField(
        help_text=_('The ID of the review request that Autoland was triggered '
                    'from.'),
        db_index=True)
    user_id = models.IntegerField(
        help_text=_('The ID of the user that triggered the Autoland job.'),
        db_index=True)
    extra_data = JSONField(
        help_text=_('Meta information about this Autoland job.'))

    class Meta:
        app_label = 'mozreview'

    @property
    def last_known_status(self):
        last_evt = self.event_log_entries.last()
        return last_evt.status if last_evt else ""

    @property
    def last_details(self):
        last_evt = self.event_log_entries.last()
        return last_evt.details if last_evt else ""

    @property
    def last_error_msg(self):
        last_evt = self.event_log_entries.last()
        return last_evt.error_msg if last_evt else ""


class AutolandEventLogEntry(models.Model):
    REQUESTED = 'R'
    PROBLEM = 'P'
    SERVED = 'S'

    STATUSES = (
        (REQUESTED, _('Request received')),
        (PROBLEM,   _('Problem encountered')),
        (SERVED,    _('Request served')),
    )

    autoland_request = models.ForeignKey(AutolandRequest,
                                         verbose_name=_('autoland_request'),
                                         related_name='event_log_entries')
    event_time = models.DateTimeField(auto_now_add=True)
    status = models.CharField(_('status'), max_length=1, choices=STATUSES,
                              db_index=True)
    details = models.TextField(_('details'), blank=True)
    error_msg = models.TextField(_('error_msg'), blank=True)

    class Meta:
        app_label = 'mozreview'


class ImportPullRequestRequest(models.Model):
    autoland_id = models.IntegerField(
        primary_key=True,
        help_text=_('The job ID that Autoland returns to us.'))
    github_user = models.CharField(
        max_length=255,
        help_text=_('The github user/org for which Autoland was asked to '
                    'land the pullrequest (e.g. mozilla).'),
        db_index=True)
    github_repo = models.CharField(
        max_length=255,
        help_text=_('The github repo name for which Autoland was asked to '
                    'land the pullrequest (e.g. gecko-dev).'),
        db_index=True)
    github_pullrequest = models.IntegerField(
        help_text=_('The pullrequest number for which Autoland was asked to '
                    'land the pullrequest (e.g. 42).'),
        db_index=True)
    bugid = models.IntegerField(
        help_text=_('The bugzilla bug id for the pullrequest.'),
        null=True)
    # Unfortunately, Review Board extensions can't take advantage of the
    # ForeignKey ORM magic that Django provides. This is because the extension
    # loading mechanism doesn't do enough (yet) to flush out the foreign key
    # caches in Django.
    review_request_id = models.IntegerField(
        help_text=_('The ID of the review request that was created from the '
                    'pullrequest'), null=True)

    class Meta:
        app_label = 'mozreview'
