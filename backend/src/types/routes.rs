#[derive(Clone, Debug, PartialEq)]
pub struct Event {
    pub location: String,
}
#[derive(Clone, Debug)]
pub struct Route {
    pub events: Vec<Event>,
    pub vehicle: String,
}

impl Route {
    pub fn new(vehicle: impl Into<String>, events: impl Into<Vec<Event>>) -> Self {
        Self {
            events: events.into(),
            vehicle: vehicle.into(),
        }
    }
}

impl Event {
    pub fn new(location: impl Into<String>) -> Self {
        Self {
            location: location.into(),
        }
    }
}
